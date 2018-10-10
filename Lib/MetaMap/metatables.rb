require 'nokogiri'
require 'time'
require_relative '../map.rb'
require_relative '../Parser/Parser.rb'

class MetaTables
	def initialize(fname,db)
		@doc = Nokogiri::XML(File.open(fname))
		@parser = Parser.new
		@db = db
	end

	def createRecords
		META_MAP.map { |node,fields|
			stmt = @db.prepare("INSERT INTO #{TABLE_MAP[node]} VALUES (#{(['?']*fields.count).join(',')})")
			@doc.xpath("//xmlns:#{node}").map { |table| 
				fields.map { |field,type| 
					value = table.css("#{field}").first.text
					@parser.parse(value,type)
				} 
			}.each { |record| stmt.execute(*record) }
			stmt.close if stmt
		}
	end

	def createTables
		META_MAP.map { |node, map|
			fields = META_MAP[node].map { |field,type|
				case field
				when "Order"
					"id #{type}"
				when "KDRelevant"
					"kdRelevant #{type}"
				else
					"#{field.gsub(/^[A-Z]/) { |n| n.downcase }} #{type}"
				end
			}.join(", ")
			"DROP TABLE IF EXISTS #{TABLE_MAP[node]};\nCREATE TABLE #{TABLE_MAP[node]} (#{fields});"
		}.join("\n")
	end

	def createIndices
		TABLE_MAP.map { |node,table| 
			"CREATE INDEX #{table}Index ON #{table} (id);"
		}.join("\n")
	end
end