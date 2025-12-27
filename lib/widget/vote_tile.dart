import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoteTile extends StatefulWidget {
  final String roomId;
  final String roundId;
  final String category;
  final String answer;

  const VoteTile({
    super.key,
    required this.roomId,
    required this.roundId,
    required this.category,
    required this.answer,
  });

  @override
  State<VoteTile> createState() => _VoteTileState();
}

class _VoteTileState extends State<VoteTile> {
  bool isVoting = false;
  String? myVote; // 'yes' | 'no'

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  DocumentReference get _voteRef => FirebaseFirestore.instance
      .collection('rooms')
      .doc(widget.roomId)
      .collection('rounds')
      .doc(widget.roundId)
      .collection('votes')
      .doc(widget.category)
      .collection('answers')
      .doc(widget.answer);

  /* -------------------------------------------------------------------------- */
  /*                                VOTAR                                       */
  /* -------------------------------------------------------------------------- */

  Future<void> _vote(String value) async {
    if (isVoting || myVote != null) return;

    setState(() {
      isVoting = true;
    });

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(_voteRef);

        final data = snap.exists ? snap.data() as Map<String, dynamic> : {};
        final voters = Map<String, dynamic>.from(data['voters'] ?? {});

        // 🔒 impede voto duplicado
        if (voters.containsKey(uid)) return;

        final yes = (data['yes'] ?? 0) as int;
        final no = (data['no'] ?? 0) as int;

        voters[uid] = value;

        tx.set(
          _voteRef,
          {
            'yes': value == 'yes' ? yes + 1 : yes,
            'no': value == 'no' ? no + 1 : no,
            'voters': voters,
          },
          SetOptions(merge: true),
        );
      });

      setState(() {
        myVote = value;
      });
    } finally {
      setState(() {
        isVoting = false;
      });
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                   UI                                       */
  /* -------------------------------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _voteRef.snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final yes = data['yes'] ?? 0;
        final no = data['no'] ?? 0;
        final voters = Map<String, dynamic>.from(data['voters'] ?? {});

        if (voters.containsKey(uid)) {
          myVote ??= voters[uid];
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔤 RESPOSTA
                Text(
                  widget.answer,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // 🔘 BOTÕES COM FEEDBACK VISUAL
                Row(
                  children: [
                    _voteButton(
                      icon: Icons.thumb_up,
                      label: yes.toString(),
                      selected: myVote == 'yes',
                      onTap: () => _vote('yes'),
                    ),
                    const SizedBox(width: 12),
                    _voteButton(
                      icon: Icons.thumb_down,
                      label: no.toString(),
                      selected: myVote == 'no',
                      onTap: () => _vote('no'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                           BOTÃO DE VOTO ANIMADO                             */
  /* -------------------------------------------------------------------------- */

  Widget _voteButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected
            ? Colors.green.shade700
            : isVoting
            ? Colors.grey.shade600
            : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton.icon(
        onPressed: selected || isVoting ? null : onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }
}
