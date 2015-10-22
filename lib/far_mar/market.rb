require 'pry'

module FarMar
  class Market
    attr_accessor :id, :name, :address, :city, :county, :state, :zip
    def initialize(market_hash)
      @id = market_hash[:id].to_i
      @name = market_hash[:name]
      @address = market_hash[:address]
      @city = market_hash[:city]
      @county = market_hash[:county]
      @state = market_hash[:state]
      @zip = market_hash[:zip]
    end

    def self.all
      if @market_array.nil?|| @market_array.empty?
        @market_array = CSV.read("support/markets.csv").map do |line|
        Market.new(
        id: line[0],
        name: line[1],
        address: line[2],
        city: line[3],
        county: line[4],
        state: line[5],
        zip: line[6])
        end
      end
      return @market_array
    end

    def self.find(id)
      market_array = CSV.read("support/markets.csv")
      matched_line = market_array.find do |line|
        line[0].to_i == id
      end
      specific_market = Market.new(
        id: matched_line[0],
        name: matched_line[1],
        address: matched_line[2],
        city: matched_line[3],
        county: matched_line[4],
        state: matched_line[5],
        zip: matched_line[6])
    end

    def vendors
      possibilities = FarMar::Vendor.all
      associated_vendors = possibilities.find_all do |each|
        @id == each.market_id
      end
      return associated_vendors
    end

    def products
      all_products = []
      self.vendors.each do |vendor|
        vendor.products.each do |product|
          all_products.push(product) if !all_products.include?(product)
        end
      end
      return all_products
    end

    def self.search(search_term)
      results = []
      FarMar::Market.all.find_all do |market|
        results.push(market) if market.name.match(/#{search_term}/i)
      end
      FarMar::Vendor.all.find_all do |vendor|
        results.push(vendor.market) if vendor.name.match(/#{search_term}/i)
      end
      return results
    end

    def pref_vendor
      self.vendors.sort_by { |vendor| vendor.revenue}.last
    end

    def preferred_vendor(date)
      self.vendors.each do |vendor|
      rev = 0
      max_rev = 0
      max_vendor = nil
       vendor.sales.each do |sale|
         if sale.purchase_time.to_date == date
           rev += sale.amount
         end
       end
        if rev > max_rev
          rev = max_rev
          max_vendor = vendor
        end
      end
      return max_vendor
    end
  end
end
