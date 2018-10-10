require 'nokogiri'
require 'sqlite3'
require_relative "./Lib/MetaMap/metatables.rb"

begin
	db = SQLite3::Database.new("Out.db")
	db.execute("PRAGMA synchronous=OFF")
	db.execute("PRAGMA count_changes=OFF")
	metaTables = MetaTables.new("Data/Meta/metadata.xml",db)
	db.transaction {
		db.execute_batch(metaTables.createTables)
		metaTables.createRecords
		#db.execute_batch(metaTables.createIndices)
	}
rescue SQLite3::Exception => e
	puts "Exception occured"
	puts e
ensure
	db.close if db
end