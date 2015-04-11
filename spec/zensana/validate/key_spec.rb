require 'spec_helper'

  class BadClass
    include Zensana::Validate::Key
  end

  class GoodClass
    include Zensana::Validate::Key
    REQUIRED_KEYS = [ :a, :b ]
    OPTIONAL_KEYS = [ :c ]
  end

describe Zensana::Validate::Key do

  describe '#required_keys' do
    it "fails if REQUIRED_KEYS not defined in class" do
      expect{BadClass.new.required_keys}.to raise_error(Zensana::UndefinedKeys)
    end

    it "finds REQUIRED_KEYS in class" do
      expect{GoodClass.new.required_keys}.to_not raise_error
      expect(GoodClass.new.required_keys).to eq(GoodClass::REQUIRED_KEYS)
    end
  end

  describe '#optional_keys' do
    it "fails if OPTIONAL_KEYS not defined in class" do
      expect{BadClass.new.optional_keys}.to raise_error(Zensana::UndefinedKeys)
    end

    it "finds OPTIONAL_KEYS in class" do
      expect{GoodClass.new.optional_keys}.to_not raise_error
      expect(GoodClass.new.optional_keys).to eq(GoodClass::OPTIONAL_KEYS)
    end
  end

  describe '#validate_keys' do
    let(:minimal)       { { :a => 1, :b => 2 } }
    let(:maximal)       { { :a => 1, :b => 2, :c => 3 } }
    let(:insufficient)  { { :a => 1 } }
    let(:invalid)       { { :a => 1, :b => 2, :d => 4 } }

    it "rejects an insufficent set of keys" do
      expect{GoodClass.new.validate_keys(insufficient)}.to raise_error(Zensana::MissingKey)
    end

    it "rejects an invalid set of keys" do
      expect{GoodClass.new.validate_keys(invalid)}.to raise_error(Zensana::UnknownKey)
    end

    it "accepts a minimal set of keys" do
      expect{GoodClass.new.validate_keys(minimal)}.to_not raise_error
    end

    it "accepts a complete set of keys" do
      expect{GoodClass.new.validate_keys(maximal)}.to_not raise_error
    end
  end
end
