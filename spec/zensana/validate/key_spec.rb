require 'spec_helper'

describe 'Zensana::Validate::Key' do

  class BadClass
    include Zensana::Validate::Key
  end

  class GoodClass
    include Zensana::Validate::Key
    REQUIRED_KEYS = @required
    OPTIONAL_KEYS = @optional
  end

  describe '#required_keys' do
    let(:bad_class)     { BadClass.new }
    let(:good_class)    { GoodClass.new }
    let(:required)      { [ :a, :b ] }
    let(:optional)      { [ :c ] }

    it "fails if REQUIRED_KEYS array not defined in class" do
      expect{bad_class.required_keys}.to raise_error(Zensana::UndefinedKeys)
    end

    it "finds REQUIRED_KEYS array in class" do
      expect{good_class.required_keys}.to_not raise_error
      expect(good_class.required_keys).to eq(@required)
    end
  end

  describe '#optional_keys' do
    let(:bad_class)     { BadClass.new }
    let(:good_class)    { GoodClass.new }
    let(:required)      { [ :a, :b ] }
    let(:optional)      { [ :c ] }

    it "fails if OPTIONAL_KEYS arrays not defined in class" do
      expect{bad_class.optional_keys}.to raise_error(Zensana::UndefinedKeys)
    end

    it "finds OPTIONAL_KEYS array in class" do
      expect{good_class.optional_keys}.to_not raise_error
      expect(good_class.optional_keys).to eq(@optional)
    end
  end

  describe '#validate_keys' do
    let(:good_class)    { GoodClass.new }
    let(:required)      { [ :a, :b ] }
    let(:optional)      { [ :c ] }

    let(:minimal)       { { :a => 1, :b => 2 } }
    let(:maximal)       { { :a => 1, :b => 2, :c => 3 } }
    let(:insufficient)  { { :a => 1 } }
    let(:invalid)       { { :a => 1, :b => 2, :d => 4 } }

    it "rejects an insufficent set of keys" do
      pending "Test fails in strange way"
      expect{good_class.validate_keys(insufficient)}.to raise_error(Zensana::MissingKey)
    end

    it "rejects an invalid set of keys" do
      pending "Test fails in strange way"
      expect{good_class.validate_keys(invalid)}.to raise_error(Zensana::UnknownKey)
    end

    it "accepts a minimal set of keys" do
      pending "Test fails in strange way"
      expect{good_class.validate_keys(minimal)}.to_not raise_error
    end

    it "accepts a complete set of keys" do
      pending "Test fails in strange way"
      expect{good_class.validate_keys(maximal)}.to_not raise_error
    end
  end
end
