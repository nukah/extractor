require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/../compare.rb'

describe "Comparator" do
  before :all do
    stub = ContentGenerator.new
    @changed = stub.changed
    @unchanged = stub.unchanged
  end
  describe "Native comparator" do
    it "should return correct added/removed" do
      added, removed = compare_native(@changed[:old_file], @changed[:new_file])
      expect(added.size).to be == @changed[:added]
      expect(removed.size).to be == @changed[:removed]
    end

    it "should return false on wrong input" do
      result = compare_native("/random/wrong")
      expect(result).to be_false
    end

    it "should return 0 when files are identical" do
      added, removed = compare_native(@unchanged[:old_file], @unchanged[:new_file])
      expect(added.size).to be == @unchanged[:added]
      expect(removed.size).to be == @unchanged[:removed]
    end
  end

  describe "Ruby comparator" do
    it "should return correct added/removed" do
      added, removed = compare(@changed[:old_file], @changed[:new_file])
      expect(added.size).to be == @changed[:added]
      expect(removed.size).to be == @changed[:removed]
    end

    it "should return false on wrong input" do
      result = compare("/random/wrong")
      expect(result).to be_false
    end

    it "should return 0 when files are identical" do
      added, removed = compare(@unchanged[:old_file], @unchanged[:new_file])
      expect(added.size).to be == @unchanged[:added]
      expect(removed.size).to be == @unchanged[:removed]
    end
  end
end