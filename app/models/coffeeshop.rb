class Coffeeshop < ApplicationRecord
    validates :name, :address, :rating, :yelp_url, :image_url, :phone_number, presence: true
    has_many :reviews
    has_many :users, through: :reviews
    has_many :user_favorites
    belongs_to :search

    def self.get_search_results(query, search)
        begin
            response = RestClient::Request.execute(
                method: "GET",
                url: "https://api.yelp.com/v3/businesses/search?term=coffee&location=#{query}",
                headers: { Authorization: "Bearer #{ENV['YELP_API_KEY']}"}
            )
            results = JSON.parse(response)
        rescue RestClient::Exception => e
            return "error"
        end
      
        coffeeshops = results["businesses"]
        create_coffee_shops_from_results(coffeeshops, search)
    end

    def self.create_coffee_shops_from_results(results, search)
        results.each do |data|
            address = data["location"]["display_address"].join(" ")
            search.coffeeshops << Coffeeshop.where(address: address).first_or_create do |c|
                c.name = data["name"].empty? ?  "No name" : data["name"]
                c.rating = data["rating"] ?  data["rating"] : 0
                c.yelp_url = data["url"].empty? ? "https://yelp.com" : data["url"] 
                c.image_url = data["image_url"].empty? ? "https://increasify.com.au/wp-content/uploads/2016/08/default-image.png" : data["image_url"] 
                c.phone_number = data["display_phone"].empty? ?  "Unknown phone number." : data["display_phone"] 
            end
        end
    end

    def google_address_slug
        self.address.gsub(/[ ,]/, " " => "+", ","  => "%2C")
    end


end
