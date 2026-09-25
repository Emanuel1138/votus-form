class Question {
  final int id;
  final String text;
  final List<String> options;

  const Question({required this.id, required this.text, required this.options});
}

// Perguntas fixas do app — edite aqui à vontade, não precisa mexer em mais nada.
const List<Question> surveyQuestions = [
  Question(
    id: 1,
    text: 'O que você achou do projeto?',
    options: ['Ótimo', 'Bom', 'Regular', 'Ruim'],
  ),
  Question(
    id: 2,
    text: 'As informações sobre os candidatos foram úteis?',
    options: ['Muito úteis', 'Úteis', 'Pouco úteis', 'Não úteis'],
  ),
  Question(
    id: 3,
    text: 'Você recomendaria o app pra outras pessoas?',
    options: ['Com certeza', 'Provavelmente', 'Talvez', 'Não'],
  ),
];