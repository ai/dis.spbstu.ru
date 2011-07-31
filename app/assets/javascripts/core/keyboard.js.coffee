app.keyboard =

  # Соответствие русских и английских букв на стандартных раскладках
  russianLayout:
    'q': 'й'
    'w': 'ц'
    'e': 'у'
    'r': 'к'
    't': 'е'
    'y': 'н'
    'u': 'г'
    'i': 'ш'
    'o': 'щ'
    'p': 'з'
    '[': 'х'
    ']': 'ъ'
    'a': 'ф'
    's': 'ы'
    'd': 'в'
    'f': 'а'
    'g': 'п'
    'h': 'р'
    'j': 'о'
    'k': 'л'
    'l': 'д'
    ';': 'ж'
    "'": 'э'
    'z': 'я'
    'x': 'ч'
    'c': 'с'
    'v': 'м'
    'b': 'и'
    'n': 'т'
    'm': 'ь'
    ',': 'б'
    '.': 'ю'
    '{': 'Х'
    '}': 'Ъ'
    ':': 'Ж'
    '"': 'Э'
    '<': 'Б'
    '>': 'Ю'

  # Переводит текст из английской расскладки в русскую
  enToRu: (english) ->
    russian = ''
    for en in english
      ru = null
      ru = @russianLayout[en]
      # Чтобы не писать прописные и строчные буквы в раскладке
      ru = @russianLayout[en.toLocaleLowerCase()]?.toLocaleUpperCase() unless ru
      russian += ru || en
    russian
