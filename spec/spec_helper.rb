RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

class ContentGenerator
  def initialize
    @base = %x(find / -type f 2>/dev/null | head -n 5000 | perl -MList::Util=shuffle -e'print shuffle<>').split("\n")[2000..4000]
  end

  def changed
    recent = @base.dup
    old = @base.dup

    removed = rand(1..100)
    added  = rand(1..100)

    removed.times { recent.delete_at(rand(1..recent.size)) }
    added.times { old.delete_at(rand(1..old.size)) }

    old_file = File.open("file_first.txt", "w")
    new_file = File.open("file_last.txt", "w")
    old_file.write(old.join("\n"))
    new_file.write(recent.join("\n"))

    { added: added, removed: removed, old_file: old_file.path, new_file: new_file.path }
  end

  def unchanged
    recent = @base.dup
    old = recent

    old_file = File.open("file_first_unchanged.txt", "w")
    new_file = File.open("file_last_unchanged.txt", "w")
    old_file.write(old.join("\n"))
    new_file.write(recent.join("\n"))

    { added: 0, removed: 0, old_file: old_file.path, new_file: new_file.path }
  end
end