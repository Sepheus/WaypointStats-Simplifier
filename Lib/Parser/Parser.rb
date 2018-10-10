require 'time'
require_relative '../map.rb'

class Parser
	#This is silly, remove before processing large volumes.
	ISO8601 = /^([\+-]?\d{4}(?!\d{2}\b))((-?)((0[1-9]|1[0-2])(\3([12]\d|0[1-9]|3[01]))?|W([0-4]\d|5[0-2])(-?[1-7])?|(00[1-9]|0[1-9]\d|[12]\d{2}|3([0-5]\d|6[1-6])))([T\s]((([01]\d|2[0-3])((:?)[0-5]\d)?|24\:?00)([\.,]\d+(?!:))?)?(\17[0-5]\d([\.,]\d+)?)?([zZ]|([\+-])([01]\d|2[0-3]):?([0-5]\d)?)?)?)?$/
	SIMPLE_DATE = /^[\d]{4}-[\d]{2}-[\d]{2}T[\d]{2}:[\d]{2}:[\d]{2}Z*$/
	BOOL = /^(true|false)$/i
	NUMBER = /^[[:digit:]]+$/
	HEX_COLOUR = /^#[[:xdigit:]]{6,8}$/
	GAME_ID = /^[[:xdigit:]]*$/
	SIGNED_NUMBER = /^-[[:digit:]]+$/
	DURATION = /^[\d]{2}:[0-5][\d]:[0-5][\d]$/
	def parse(value,type)
		case
			when value =~ HEX_COLOUR && (type == DB_INT)
				value[1..-1].to_i(16)
			when value =~ GAME_ID && (type == DB_BIGINT)
				[value.to_i(16)].pack("Q>")
			when value =~ SIGNED_NUMBER && (type == DB_INT)
				value.to_i&0xFFFFFFFF
			when value =~ SIMPLE_DATE && (type == DB_DATETIME)
				Time.iso8601(value).to_i
			when value =~ BOOL && (type == DB_BOOL)
				value.downcase == "true" ? 1 : 0
			when value.class == TrueClass && (type == DB_BOOL)
				1
			when value.class == FalseClass && (type == DB_BOOL)
				0
			when value =~ DURATION && (type == DB_MEDIUMINT)
				value.split(":").each_slice(3).map { |a,b,c| a.to_i*60*2 + b.to_i*60 + c.to_i }.first
			else
				value
		end 
	end
end