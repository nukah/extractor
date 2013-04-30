def compare(f1, f2)
  CHUNK_SIZE = 2**27
  MULTIPLIER = 1
  [f1,f2].each { |file|
    abort("'#{file}' does not exist or not readable") unless File.exist?(file) && File.readable?(file)
  }

  removed = []
  added = []

  extractor = Proc.new do |fs1, fs2|
    b_o = fs1.next
    b_n = fs2.next

    b_o.map { |e| e.strip }
    b_n.map { |e| e.strip }

    added_files = b_n - b_o
    removed_files = b_o - b_n

    [added_files, removed_files]

  end

  io1 = File.open(f1, "r").each_slice(CHUNK_SIZE)
  io2 = File.open(f2, "r").each_slice(CHUNK_SIZE)

  workers = File.size(f1).fdiv(CHUNK_SIZE*MULTIPLIER).ceil

  workers.times {
    Fiber.new {
      begin
        a,r = extractor.call(io1, io2)
        added.push(a).flatten!
        removed.push(r).flatten!
      rescue StopIteration
      end
    }.resume
  }
  # File.open("added_files.txt", "w+") { |f| f.puts(added) } if added.any?
  # File.open("removed_files.txt", "w+") { |f| f.puts(removed) } if removed.any?
  # (puts "Added files"; added.each { |p| puts p }) if added.any?
  # (puts "Removed files"; removed.each { |p| puts p }) if removed.any?
end

def compare2(f1, f2)
  [f1,f2].each { |file|
    abort("'#{file}' does not exist or not readable") unless File.exist?(file) && File.readable?(file)
  }

  removed = []
  added = []

  extractor = Proc.new do |fs1, fs2|
    b_o = fs1.next
    b_n = fs2.next

    b_o.map { |e| e.strip }
    b_n.map { |e| e.strip }

    added_files = b_n - b_o
    removed_files = b_o - b_n

    [added_files, removed_files]

  end

  file1 = File.open(f1, "r")
  io1 = file1.each_slice(CHUNK_SIZE)
  file2 = File.open(f2, "r")
  io2 = file2.each_slice(CHUNK_SIZE)

  until io1.eof? && io2.eof? do
    begin
      a,r = extractor.call(io1, io2)
      added.push(a).flatten!
      removed.push(r).flatten!
    rescue StopIteration
    end
  end
  # File.open("added_files.txt", "w+") { |f| f.puts(added) } if added.any?
  # File.open("removed_files.txt", "w+") { |f| f.puts(removed) } if removed.any?
  # (puts "Added files"; added.each { |p| puts p }) if added.any?
  # (puts "Removed files"; removed.each { |p| puts p }) if removed.any?
end
