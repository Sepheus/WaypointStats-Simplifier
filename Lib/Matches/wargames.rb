require 'moped'
require 'sqlite3'
require 'benchmark'
require_relative './../map.rb'
require_relative './../Parser/parser.rb'

class WarGamesTables

	STATS_WAR_GAMES_TABLE = "statsWargames"
	STATS_TEAMS_TABLE = "statsTeams"
	PLAYER_TAGS_TABLE = "playerTags"
	STATS_PLAYERS_TABLE = "statsPlayers"

	VALUE = -> (x) { x }
	BOOLEAN = -> (x) { x ? 1 : 0 }
	DURATION = -> (x) { x.split(":").inject(0) { |a,b| a*60 + b.to_i } }
	GAME_ID = -> (x) { [x.to_i(16)].pack("Q>") }

	GAME_MAP = {
		"uid" => VALUE,
		"gameId" => GAME_ID,
		"PlaylistId" => VALUE,
		"MapId" => VALUE,
		"Duration" => DURATION,
		"TotalPlayers" => VALUE,
		"ModeId" => VALUE,
		"GameBaseVariantId" => VALUE,
		"Completed" => BOOLEAN
	}

	GAME_QUERY = ["Game.PlaylistId", "Game.MapId", "Game.Duration", "Game.TotalPlayers", "Game.ModeId", "Game.GameBaseVariantId", "Game.Completed"]
	TEAM_QUERY = ["Game.Teams.Id", "Game.Teams.Score", "Game.Teams.Kills", "Game.Teams.Deaths", "Game.Teams.Assists", "Game.Teams.Betrayals", "Game.Teams.Suicides", "Game.Teams.Standing"]
	GAME_FIELDS = ["uid","gameId","PlaylistId","MapId","Duration","TotalPlayers","ModeId","GameBaseVariantId","Completed"]
	TEAM_FIELDS = ["uid", "gameId", "Id", "Score", "Kills", "Deaths", "Assists", "Betrayals", "Suicides", "Standing"]

	PLAYER_QUERY = {"Game.Players.Gamertag" => 1, "Game.Players.Servicetag" => 1, "Game.Players.TeamId" => 1, "Game.Players.PersonalScore" => 1, "Game.Players.Kills" => 1, "Game.Players.Deaths" => 1, "Game.Players.Assists" => 1, "Game.Players.Betrayals"  => 1, "Game.Players.Suicides" => 1, "Game.Players.Headshots" => 1}
	PLAYER_FIELDS = ["playerId","gameId","TeamId","PersonalScore","Kills","Deaths","Assists","Betrayals","Suicides","Headshots"]

	BIG_QUERY = [GAME_QUERY,TEAM_QUERY].flatten

	def initialize(gameDB,db)
		@db = db
		@gameDB = gameDB
		@tags = {}
		@games = {}
	end

	def createRecords
		games = @gameDB.find.select(Hash[BIG_QUERY.map { |n| [n,1] }]).batch_size(1000)
		players = @gameDB.find.select(PLAYER_QUERY).batch_size(500)
		gameStmt = @db.prepare("INSERT INTO #{STATS_WAR_GAMES_TABLE} VALUES (?,?,?,?,?,?,?,?,?)")
		teamStmt = @db.prepare("INSERT INTO #{STATS_TEAMS_TABLE} VALUES (?,?,?,?,?,?,?,?,?,?)")
		tagsStmt = @db.prepare("INSERT INTO #{PLAYER_TAGS_TABLE} (gamertag, servicetag, id) VALUES (?,?,?)")
		playerStmt = @db.prepare("INSERT INTO #{STATS_PLAYERS_TABLE} (playerId, gameId, teamId, score, kills, deaths, assists, betrayals, suicides, headshots) VALUES (?,?,?,?,?,?,?,?,?,?)")
		gameId = 0
		teamId = 0
		playerId = 0
		time = Benchmark.realtime {
			games.each_slice(1000) { |batch|
				batch.map { |n| 
					n["Game"]["uid"] = gameId+=1
					n["Game"]["gameId"] = n["_id"]
					@games[n["_id"]] = gameId
				 	n["Game"] 
				}
				.each { |game|
				 	gameStmt.execute(GAME_FIELDS.map { |n| GAME_MAP[n].call(game[n]) }) 
				}
				.each { |game|
					game["Teams"].each { |team| 
						team["uid"] = teamId+=1
						team["gameId"] = game["uid"]
						teamStmt.execute(TEAM_FIELDS.map { |n| team[n] })
					}
				}
			}
			players.each_slice(500) { |batch| 
				batch.map { |n| 
					n["Game"]["Players"].each { |player| 
						@tags[player["Gamertag"]] = @tags[player["Gamertag"]].nil? ? [player["Servicetag"],playerId+=1] : @tags[player["Gamertag"]]
						player["playerId"] = @tags[player["Gamertag"]][1]
						player["gameId"] = @games[n["_id"]]
						playerStmt.execute(PLAYER_FIELDS.map { |n| player[n] })
					}
				}
			}
			@tags.each { |record| tagsStmt.execute(record.flatten) }
		}
		gameStmt.close if gameStmt
		teamStmt.close if teamStmt
		tagsStmt.close if tagsStmt
		playerStmt.close if playerStmt
		puts "Time elapsed: #{time}"
	end

	def createTables
		war_games_tables =  <<SQL
		DROP TABLE IF EXISTS #{STATS_WAR_GAMES_TABLE};
		DROP TABLE IF EXISTS #{STATS_TEAMS_TABLE};
		DROP TABLE IF EXISTS #{PLAYER_TAGS_TABLE};
		DROP TABLE IF EXISTS #{STATS_PLAYERS_TABLE};
		CREATE TABLE #{STATS_WAR_GAMES_TABLE}(
			id INTEGER PRIMARY KEY, gameId BIGINT, playlistId TINYINT, mapId SMALLINT, duration MEDIUMINT, totalPlayers TINYINT, modeId TINYINT, gameBaseVariantId TINYINT, completed TINYINT,
			FOREIGN KEY(`playlistId`) REFERENCES `#{META_PLAYLISTS_TABLE}`(`id`),
			FOREIGN KEY(`mapId`) REFERENCES `#{META_MAPS_TABLE}`(`id`),
			FOREIGN KEY(`modeId`) REFERENCES `#{META_GAME_MODES_TABLE}`(`id`),
			FOREIGN KEY(`gameBaseVariantId`) REFERENCES `#{META_GAME_BASE_VARIANTS_TABLE}`(`id`)
		);
		CREATE TABLE #{STATS_TEAMS_TABLE}(
			id INTEGER PRIMARY KEY, gameId INTEGER, teamId TINYINT, score SMALLINT, kills SMALLINT, deaths SMALLINT, assists SMALLINT, betrayals SMALLINT, suicides SMALLINT, standing TINYINT,
			FOREIGN KEY(`gameId`) REFERENCES `#{STATS_WAR_GAMES_TABLE}`(`id`),
			FOREIGN KEY(`teamId`) REFERENCES `#{META_TEAMS_TABLE}`(`id`)
		);
		CREATE TABLE #{PLAYER_TAGS_TABLE} (id INTEGER PRIMARY KEY, gamertag TEXT, servicetag TEXT);
		CREATE TABLE #{STATS_PLAYERS_TABLE}(id INTEGER PRIMARY KEY AUTOINCREMENT, playerId INTEGER, gameId INTEGER, teamId TINYINT, score SMALLINT, kills SMALLINT, deaths SMALLINT, assists SMALLINT, betrayals SMALLINT, suicides SMALLINT, headshots SMALLINT,
			FOREIGN KEY(`playerId`) REFERENCES `#{PLAYER_TAGS_TABLE}`(`id`),
			FOREIGN KEY(`gameId`) REFERENCES `#{STATS_WAR_GAMES_TABLE}`(`id`),
			FOREIGN KEY(`teamId`) REFERENCES `#{STATS_TEAMS_TABLE}`(`id`)
		);
SQL
		war_games_tables
	end

end


begin
	gameDB = Moped::Session.new(["127.0.0.1:27017"])
	gameDB.use :halofour
	db = SQLite3::Database.new("../../Out.db")
	wg = WarGamesTables.new(gameDB[:war_games],db)
	
	db.execute("PRAGMA synchronous=OFF")
	db.execute("PRAGMA count_changes=OFF")
	db.transaction {
		db.execute_batch(wg.createTables)
		wg.createRecords
	}
rescue SQLite3::Exception => e
	puts "Exception occured"
	puts e
ensure
#	db.close if db
end