require "net/https"
require 'mechanize'

module Dobber

  class Dob
    attr_reader :token

    def initialize(token)
      @token = token
    end

    def spit
      http               = Net::HTTP.new("nosnch.in", 443)
      http.use_ssl       = true
      response           = http.request(Net::HTTP::Get.new("/#{@token}"))
      response.code_type == Net::HTTPOK
    end
  end

  class Dobbings
    def initialize(login, password, snitch_id)
      @login        = login
      @password     = password
      @snitch_url   = "http://deadmanssnitch.com/snitches/#{snitch_id}"
    end

    def status
      agent         = Mechanize.new
      login_page    = agent.get(@snitch_url)
      form          = login_page.form_with(action: '/users/sign_in')
      form.send("user[email]",@login)
      form.send("user[password]",@password)
      my_snitch     = agent.submit(form)
      snitch_page   = agent.get(@snitch_url)
      
      if snitch_page.title =~ /^(\s*)Sign In/
        raise "Login failed for user #{@login}"
      end
      
      if snitch_page.search('.snitch').first.attributes["class"].value =~ /healthy/
        is_healthy = true
      else
        is_healthy = false
      end

      healthy = snitch_page.search('.periods').flat_map { |p|
        p.search('.healthy').map {|f| {:expected => f.attributes["data-key"].value, :sent => f.search(".period-details").search("strong").text} }
      }
      failed = snitch_page.search('.periods').flat_map { |p|
        p.search('.failed').map {|f| f.attributes["data-key"].value }
      }
      last_check_at     = snitch_page.search('.lcd').children.search("time").first.attributes["datetime"].value
      last_check_human  = snitch_page.search('.lcd').children.search("time").first.child.text
      {
        is_healthy:           is_healthy,
        last_check_at:        last_check_at,
        last_check_human:     last_check_human,
        healthy:              healthy,
        failed:               failed,
      }
    end
  end

  class << self

    def dob(spittle)
      Dob.new(spittle).spit
    end

    def dobbings(email, password, snitch_id)
      Dobbings.new(email, password, snitch_id).status
    end
  end
end
