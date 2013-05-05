CHUNK_SIZE = 2**22
MULTIPLIER = 1
## Функция выделения изменившихся путей средствами Ruby
# Params:
# +old+:: Файл со списком путей предыдущей версии
# +recent+:: Файл со списком путей новой версии
def compare(old = nil, recent = nil)
  [old, recent].each { |file|
    # Проверка существования каждого из файлов и проверка возможности чтения файлов
    # В случае несуществующего пути или недоступного файла выводит false
    return false unless file && File.exist?(file) && File.readable?(file)
  }
  added, removed = [], []
  # Процедура вычленения изменившихся файлов, принимает два параметра - объекты типа Enumerator
  extractor = Proc.new do |fs1, fs2|
    # Вызываются следующие блоки данных из обоих файлов
    b_o = fs1.next
    b_n = fs2.next
    # Проводится вычленение нужных элементов путём пересечения массивов в одном и в другом направлении
    added_files = b_n - b_o
    removed_files = b_o - b_n
    # Процедура отдаёт массив с двумя субмассивами добавленных и удалённых файлов
    [added_files, removed_files]
  end
  # Открываются файловые потоки по обоим файлам.
  # Потоки бьются на куски размером +CHUNK_SIZE+ байт.
  old_file_stream = File.open(old, "r").each_slice(CHUNK_SIZE)
  new_file_stream = File.open(recent, "r").each_slice(CHUNK_SIZE)

  # Высчитывается количество запусков процедуры вычленения исходя из количества блоков размером +CHUNK_SIZE+ в исходном файле.
  workers = File.size(old).fdiv(CHUNK_SIZE*MULTIPLIER).ceil
  # Запускается Fiber с процедурой вычленения данных.
  workers.times {
    Fiber.new {
      begin
        a,r = extractor.call(old_file_stream, new_file_stream)
        added.push(a).flatten!
        removed.push(r).flatten!
      rescue StopIteration
      end
    }.resume
  }
  # Выводом является массив со списками значений добавленных и удалённых файлов
  [added, removed]
end

## Функция выделения изменившихся путей через средства *nix
# Params:
# +old+:: Файл со списком путей предыдущей версии
# +recent+:: Файл со списком путей новой версии
def compare_native(old = nil, recent = nil)
  # Проверка существования каждого из файлов и проверка возможности чтения файлов
  # В случае несуществующего пути или недоступного файла выводит false
  [old,recent].each { |file|
    return false unless file && File.exist?(file) && File.readable?(file)
  }
  # Подход работает только на платформах *nix
  return false if RUBY_PLATFORM.downcase.include?("mswin")
  added, removed = [], []
  # Результат вызова diff на оба файла выводится в массив Array
  diff = %x(diff -wBE --speed-large-files #{old} #{recent}).split("\n")
  # Каждый из элементов проходит проверки
  diff.each { |e|
    # Отсекается ненужный вывод от diff, оставляя только изменения и флаг привязки к файлу
    next unless /^[<>]\s.*$/.match(e)
    # Выводится направление изменений и изменившийся элемент
    direction, element = e.split
    # Элементы с флагом "<"" добавляются в список удалённых файлов, элементы с флагом ">" в список добавленных
    direction == "<" and removed.push(element) or added.push(element)
  }
  # Выводом является массив со списками значений добавленных и удалённых файлов
  [added, removed]
end