class Question {
  final int id;
  final String text;
  final List<String> options;

  const Question({
    required this.id,
    required this.text,
    required this.options,
  });
}

// Perguntas da pesquisa.
// Escala de concordância:
// 1 = Discordo totalmente
// 5 = Concordo totalmente
//
// Escala de frequência:
// 1 = Nunca
// 5 = Sempre

const List<Question> surveyQuestions = [
  Question(
    id: 1,
    text:
        'As informações são apresentadas de forma clara e organizada.',
    options: [
      '1 - Discordo totalmente',
      '2 - Discordo',
      '3 - Neutro',
      '4 - Concordo',
      '5 - Concordo totalmente',
    ],
  ),
  Question(
    id: 2,
    text:
        'Consigo utilizar o sistema sem precisar de treinamento ou ajuda externa.',
    options: [
      '1 - Discordo totalmente',
      '2 - Discordo',
      '3 - Neutro',
      '4 - Concordo',
      '5 - Concordo totalmente',
    ],
  ),
  Question(
    id: 3,
    text:
        'As etapas necessárias para realizar uma tarefa no sistema são simples e lógicas.',
    options: [
      '1 - Discordo totalmente',
      '2 - Discordo',
      '3 - Neutro',
      '4 - Concordo',
      '5 - Concordo totalmente',
    ],
  ),
  Question(
    id: 4,
    text:
        'O sistema contribui para solucionar o problema apresentado.',
    options: [
      '1 - Discordo totalmente',
      '2 - Discordo',
      '3 - Neutro',
      '4 - Concordo',
      '5 - Concordo totalmente',
    ],
  ),
  Question(
    id: 5,
    text:
        'Eu utilizaria o sistema com frequência para acompanhar notícias e o histórico de candidatos.',
    options: [
      '1 - Nunca',
      '2 - Raramente',
      '3 - Às vezes',
      '4 - Frequentemente',
      '5 - Sempre',
    ],
  ),
];