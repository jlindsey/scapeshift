require 'helper'

class CardTest < Test::Unit::TestCase
  context "A Card object" do
    setup do
      @params = { :name => "Mind Spring", :cost => "XBB",
        :types => ["Sorcery"], :text => "Draw X cards.",
        :sets => [["Magic 2010", "Rare"], ["Morningtide", "Rare"]],
        :image_uri => "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=191323&type=card"}

      @card = Scapeshift::Card.new @params
    end

    should "instantiate correctly with parameters" do
      assert_instance_of Scapeshift::Card, @card
      
      assert_equal @params[:name], @card.name
      assert_equal @params[:cost], @card.cost
      assert_equal @params[:types], @card.types
      assert_equal @params[:text], @card.text
      assert_equal @params[:sets], @card.sets
      assert_equal @params[:image_uri], @card.image_uri
    end

    should "correctly report the most recent set and rarity" do
      assert_equal @params[:sets].first[0], @card.set
      assert_equal @params[:sets].first[1], @card.rarity
    end
  end
end

