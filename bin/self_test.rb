#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/sky_ca"

ca = SkyCA::Authority.new(common_name: "Sky CA Self Test", validity_days: 30)
issued = ca.issue(common_name: "service.internal", validity_days: 7, serial: 1)
abort "certificate verification failed" unless ca.verify(issued.fetch(:certificate_pem))
puts "sky-ca self-test passed"
