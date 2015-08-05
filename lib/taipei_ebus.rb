require "taipei_ebus/version"
require 'nokogiri'
require 'open-uri'
require 'json'

module TaipeiEbus

  class Client

    EBUS_URL = [
      "http://e-bus.taipei.gov.tw/newmap",
      "http://e-bus.ntpc.gov.tw/NTPCRoute",
      "http://e-bus.ntpc.gov.tw/SingleRoute"
    ]

    #
    # get all buslines
    # 
    # @return an array of hash objects: [ { :title => "xxx", :rid => nnn, :url_id => n }, ... ]
    #
    def get_buslines
      json_busline_lists = []

      url = "http://e-bus.ntpc.gov.tw/"
      json_busline_lists = get_category_buslines(url, json_busline_lists)

      url = "http://e-bus.ntpc.gov.tw/mrt-bus.html"
      json_busline_lists = get_category_buslines(url, json_busline_lists)

      url = "http://e-bus.ntpc.gov.tw/new-bus.html"
      json_busline_lists = get_category_buslines(url, json_busline_lists)

      url = "http://e-bus.ntpc.gov.tw/taipei-bus.html"
      json_busline_lists = get_category_buslines(url, json_busline_lists)

      return json_busline_lists
    end

    #
    # get busline info by title
    # 
    # @param title: a busline title (string)
    # @param buslines: a list of busline (hash array)
    # 
    # @return a json object: { :title => "xxx", :rid => nnn, :url_id => n }
    # 
    # @example
    #     get_busline_info_by_title("241"), or
    #     get_busline_info_by_title("241", buslines)
    #
    def get_busline_info_by_title(title, buslines=[])
      busline = {}
      if (buslines == [])
        buslines = get_buslines
      end

      buslines.each do |bus|
        if (title == bus[:title])
          busline = bus
          break
        end
      end

      return busline
    end

    #
    # get busline stops
    # 
    # @param rid: route id (string)
    # @param url_id: index value of EBUS_URL[] (string or number)
    # @param direction: 0 (go) or 1 (back)
    # 
    # @return a hash of object
    #   { :go => [ { :idx => nn, :name => "xxx" }, ... ], :back => [ ... ] }
    # 
    # @example
    #     get_busline_stops("5220", 1), or
    #     get_busline_stops("5220", 1, 0)
    #     
    #     go url: http://e-bus.ntpc.gov.tw/NTPCRoute/Tw/Map?rid=5220&sec=0
    #     back url: http://e-bus.ntpc.gov.tw/NTPCRoute/Tw/Map?rid=5220&sec=1
    #
    def get_busline_stops(rid, url_id, direction={})
      route_stops = { :go => [], :back => [] }

      if (url_id.to_i >= 0 && url_id.to_i < EBUS_URL.length)
        url = "#{EBUS_URL[url_id.to_i]}/Tw/Map?rid=#{rid}&sec="

        if ( direction == {} || direction.to_i == 0)
          # get GO stop list
          doc = Nokogiri::HTML( open( url + "0"), nil, 'UTF-8')
          (doc.css('//div.stopName')).each_with_index { | stop_name, i|
            route_stops[:go] << { :idx => i,  :name => stop_name.text }
          }
        end

        if ( direction == {} || direction.to_i == 1)
          # get BACK stop list
          doc = Nokogiri::HTML( open( url + "1"), nil, 'UTF-8')
          (doc.css('//div.stopName')).each_with_index { | stop_name, i|
            route_stops[:back] << { :idx => i,  :name => stop_name.text }
          }
        end
      end

      return route_stops
    end

    #
    # get route real time information update
    # 
    # @param rid: route id (string)
    # @param url_id: index value of EBUS_URL[] (string or number)
    # @param direction: 0 (go) or 1 (back)
    # 
    # @return a hash of object
    #     { :go => { :Etas => [ { :idx => nn, :eta => nnn }, ... ], :Buses => [ { :bn => "xxx", :idx => nn, :fl => "x", :io => "x" }, ... ] }, :back => { ... } }
    # 
    # @example
    #     get_busline_current_update("5220", 1), or
    #     get_busline_current_update("5220", 1, 0)
    # 
    #     go url: http://e-bus.ntpc.gov.tw/NTPCRoute/Js/RouteInfo?rid=5220&sec=0
    #     back url: http://e-bus.ntpc.gov.tw/NTPCRoute/Js/RouteInfo?rid=5220&sec=1
    #
    def get_busline_current_update(rid, url_id, direction={})
      busline_update = { :go => {}, :back => {} }

      if (url_id.to_i >= 0 && url_id.to_i < EBUS_URL.length)
        url = "#{EBUS_URL[url_id.to_i]}/Js/RouteInfo?rid=#{rid}&sec="

        if ( direction == {} || direction.to_i == 0)
          doc = Nokogiri::HTML( open( url + "0"))
          if (doc.css('//body p').inner_html.include?("Etas"))
            busline_update[:go] = recursive_symbolize_keys(JSON.parse( doc.css('//body p').inner_html ))
          end
        end

        if ( direction == {} || direction.to_i == 1)
          doc = Nokogiri::HTML( open( url + "1"))
          if (doc.css('//body p').inner_html.include?("Etas"))
            busline_update[:back] = recursive_symbolize_keys(JSON.parse( doc.css('//body p').inner_html ))
          end
        end
      end

      return busline_update
    end

    def parse_eta(eta)
      eta_string = "";
      if (eta == 255)
        eta_string = "未發車";
      elsif (eta == 254)
        eta_string = "末班車已過";
      elsif (eta == 253)
        eta_string = "交管不停靠";
      elsif (eta == 252)
        eta_string = "今日未營運";
      elsif (eta < 3)
        eta_string = "將到站";
      else
        eta_string = "約 " + eta.to_s + " 分";
      end

      return eta_string;      
    end

    private
    def get_category_buslines(url, json_buslines)
      doc = Nokogiri::HTML( open( url), nil, 'UTF-8')
      buslines = doc.css("div.busLine ul li a")
      buslines.each_with_index { | busline, i|
        title = busline.text.strip
        # extract route id
        route_id = busline["href"].split(/rid=(.*?)&sec=/)[1]
        if (busline["href"].include?("newmap"))
          url_id = 0
        elsif (busline["href"].include?("NTPCRoute"))
          url_id = 1
        elsif (busline["href"].include?("SingleRoute"))
          url_id = 2
        else
          url_id = 3
        end

        json_buslines << { :title => title, :rid => route_id, :url_id => url_id }
      }

      return json_buslines
    end # get_category_buslines

    #
    # turns all string type keys into symbols, also the nested ones
    #
    def recursive_symbolize_keys(obj)
      case obj
      when Hash
        Hash[
          obj.map do |key, value|
            [ key.respond_to?(:to_sym) ? key.to_sym : key, recursive_symbolize_keys(value) ]
          end
        ]
      when Enumerable
        obj.map { |value| recursive_symbolize_keys(value) }
      else
        obj
      end
    end # recursive_symbolize_keys

  end # /class
end # /module
