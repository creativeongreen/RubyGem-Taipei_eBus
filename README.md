# TaipeiEbus

Ruby gem for Taipei ebus API

## Installation

Add this line to your application's Gemfile:

    gem 'taipei_ebus'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install taipei_ebus

## Usage

usage instructions:
- the gem require 'nokogiri', please install it

##### taipei_ebus = TaipeiEbus::TaipeiEbus.new

- new an instance object

##### buslines = taipei_ebus.get_buslines

- to get a list of buslines
- the method will return a json array containing the following information: 
- [ { :title => "xxx", :rid => nnn, :url_id => n }, ... ]

- to get busline information
- the method will return a json object regarding this specific busline: 
- { :title => "xxx", :rid => nnn, :url_id => n }

##### busline = taipei_ebus.get_busline_info_by_title( busline_title, buslines )
##### busline = taipei_ebus.get_busline_info_by_title( busline_title )

- given parameter
- busline_title = buslines[0][:title] - or -
- busline_title = "241"

##### busline_stops = taipei_ebus.get_busline_stops( rid, url_id, direction )
##### busline_stops = taipei_ebus.get_busline_stops( rid, url_id )

- to get busline stops
- the method will return a json object: 
- { :go => [ { :idx => nn, :name => "xxx" }, ...], :back => [] }

- given parameter
- rid which is provided from method get_busline_info_by_title, example: busline[:rid]
- url_id which is provided from method get_busline_info_by_title, example: busline[:url_id]
- direction: value 0 or 1 or dismiss means query both {:go} and {:back} data if any

##### busline_update = taipei_ebus.get_busline_current_update( rid, url_id, direction )
##### busline_update = taipei_ebus.get_busline_current_update( rid, url_id )

- to get busline real-time update information
- the method will return a json object:
- { :go => { :Etas => [ { :idx => nn, :eta => nnn }, ...], 
- :Buses => [ { :bn => "xxx", :idx => nn, :fl => "x", :io => "x" }, ...] }, :back => {} }

##### taipei_ebus.parse_eta( eta )

- parse eta information
- the method return a string containing the meaning of eta
- eta can be get from busline_update as above

## Contributing

1. Fork it ( https://github.com/[my-github-username]/taipei_ebus/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
