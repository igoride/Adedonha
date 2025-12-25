// ================================
// lib/core/scoring/stop_scoring.dart
// ================================

int calcularPontuacaoOficial(
    Map<String, String> respostas,
    String letra,
    List<Map<String, String>> respostasOutrosJogadores,
    ) {
  int total = 0;

  respostas.forEach((categoria, resposta) {
    if (resposta.isEmpty || !resposta.toUpperCase().startsWith(letra)) {
      return; // 0 pontos
    }

    bool repetida = respostasOutrosJogadores.any(
          (outro) => outro[categoria]?.toUpperCase() == resposta.toUpperCase(),
    );

    total += repetida ? 5 : 10;
  });

  return total;
}
