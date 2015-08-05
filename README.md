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

You can see demo [here](http://cog101.herokuapp.com/myebus/jq).

> the gem require 'nokogiri', please install it

to new an instance object:

    taipei_ebus = TaipeiEbus::Client.new

get a list of buslines:

    buslines = taipei_ebus.get_buslines

> return an array of hash objects containing the following information: 
> - [ { :title => "xxx", :rid => nnn, :url_id => n }, ... ]

get busline information by title: 

    busline = taipei_ebus.get_busline_info_by_title( busline_title, buslines )
    busline = taipei_ebus.get_busline_info_by_title( busline_title )

> return a hash of json object regarding this specific busline: 
> - { :title => "xxx", :rid => nnn, :url_id => n }

> given parameters:
> - busline_title: buslines[0][:title] or assign a string value, example: "241"
> - buslines: get from method 'get_buslines'

get busline stops:

    busline_stops = taipei_ebus.get_busline_stops( rid, url_id, direction )
    busline_stops = taipei_ebus.get_busline_stops( rid, url_id )

> return a json object: 
> - { :go => [ { :idx => nn, :name => "xxx" }, ...], :back => [] }

> given parameters:
> - rid: provided from method 'get_busline_info_by_title', example: busline[:rid]
> - url_id: provided from method 'get_busline_info_by_title', example: busline[:url_id]
> - direction: value 0 or 1, or dismiss will query both {:go} and {:back} data if any

get busline real-time update information:

    busline_update = taipei_ebus.get_busline_current_update( rid, url_id, direction )
    busline_update = taipei_ebus.get_busline_current_update( rid, url_id )

> return a json object:
> - { :go => { :Etas => [ { :idx => nn, :eta => nnn }, ...], :Buses => [ { :bn => "xxx", :idx => nn, :fl => "x", :io => "x" }, ...] }, :back => {} }

parse eta information:

    taipei_ebus.parse_eta( eta )

> return a string containing the meaning of eta

> eta can be get from 'busline_update' as above

## Contributing

1. Fork it ( https://github.com/[my-github-username]/taipei_ebus/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
