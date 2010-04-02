require 'helper'

class CardTest < Test::Unit::TestCase
  context "A Card object with complex types" do
    setup do
      @types_str = "Legendary Artifact Creature - Human Wizard"
      @card = Scapeshift::Card.new
      @card.types = @types_str
    end
    
    should "parse the types string correctly" do
      assert_equal %w{Legendary}, @card.supertypes
      assert_equal %w{Artifact Creature}, @card.base_types
      assert_equal %w{Human Wizard}, @card.subtypes
    end

    should "display the string representation of its types" do
      assert_equal @types_str, @card.types
    end
  end

  context "A Card object with several sets and rarities" do
    setup do
      printings = [["Magic 2010", "Rare"], ["Tenth Edition", "Uncommon"]]
      @card = Scapeshift::Card.new :sets => printings
    end

    should "display its most recent set" do
      assert_equal "Magic 2010", @card.set
    end

    should "display its most recent rarity" do
      assert_equal "Rare", @card.rarity
    end
  end

  context "A Card object that was instantiated with a Hash" do
    setup do
      @params = { :name => "Mind Spring", :cost => "XBB",
        :types => "Sorcery", :text => "Draw X cards.",
        :sets => [["Magic 2010", "Rare"], ["Morningtide", "Rare"]],
        :image_id => 191323 }

      @card = Scapeshift::Card.new @params
    end

    should "have its attributes set properly" do
      assert_instance_of Scapeshift::Card, @card

      assert_equal @params[:name], @card.name
      assert_equal @params[:cost], @card.cost
      assert_equal @params[:types], @card.types
      assert_equal @params[:text], @card.text
      assert_equal @params[:sets], @card.sets
      assert_equal 'http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=191323&type=card', @card.image_uri
    end
  end
end

