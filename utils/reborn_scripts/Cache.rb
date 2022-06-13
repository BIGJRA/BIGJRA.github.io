class Cache_Game
    attr_accessor :pkmn_dex
    attr_accessor :pkmn_metrics
    attr_accessor :pkmn_moves
    attr_accessor :pkmn_egg
    attr_accessor :pkmn_move
    attr_accessor :pkmn_evo
    attr_accessor :move2anim
    attr_accessor :tm_data
    attr_accessor :items
    attr_accessor :trainers
    attr_accessor :trainertypes
    attr_accessor :FEData
    attr_accessor :FENotes
    attr_accessor :mapinfos
    attr_accessor :regions
    attr_accessor :encounters
    attr_accessor :metadata
    attr_accessor :map_conns
    attr_accessor :town_map
    attr_accessor :animations
    attr_accessor :RXsystem
    attr_accessor :RXevents
    attr_accessor :RXtilesets
    attr_accessor :RXanimations
    attr_accessor :cachedmaps

    #Caching functions
    def cacheDex
        pbCompilePokemonData if !File.exists?("Data/dexdata.dat")
        @pkmn_dex           = load_data("Data/dexdata.dat") if !@pkmn_dex
        @pkmn_metrics       = load_data("Data/metrics.dat") if !@pkmn_metrics
        @pkmn_moves         = load_data("Data/attacksRS.dat") if !@pkmn_moves
        @pkmn_egg           = load_data("Data/eggEmerald.dat") if !@pkmn_egg
        @pkmn_evo           = load_data("Data/evolutions.dat") if !@pkmn_evo
    end

    def cacheMoves
        pbCompileMoves if !File.exists?("Data/moves.dat")
        @pkmn_move          = load_data("Data/moves.dat") if !@pkmn_move
        @move2anim          = load_data("Data/move2anim.dat") if !@move2anim
        @tm_data            = load_data("Data/tm.dat") if !@tm_data
    end

    def cacheItems
        pbCompileItems if !File.exists?("Data/items.dat")
        @items           = load_data("Data/items.dat") if !@items
    end

    def cacheTrainers
        if !File.exists?("Data/trainers.dat")
            pbCompileTrainers 
            pbCompileTrainerLists
        end
        @trainers           = load_data("Data/trainers.dat") if !@trainers
        @trainertypes       = load_data("Data/trainertypes.dat") if !@trainertypes
    end

    def cacheFields
        compileFields if !File.exists?("Data/fields.dat")
        @FEData             = load_data("Data/fields.dat") if !@FEData
        @FENotes            = load_data("Data/fieldnotes.dat") if !@FENotes
    end

    def cacheMapInfos
        @mapinfos           = load_data("Data/MapInfos.rxdata") if !@mapinfos
    end

    def cacheMetadata
        @regions            = load_data("Data/regionals.dat") if !@regions
        @encounters         = load_data("Data/encounters.dat") if !@encounters
        @metadata           = load_data("Data/metadata.dat") if !@metadata
        @map_conns          = load_data("Data/connections.dat") if !@map_conns
        @town_map           = load_data("Data/townmap.dat") if !@town_map
        PBTypes.loadTypeData
        #MessageTypes.loadMessageFile("Data/Messages.dat")
    end

    def initialize
        cacheDex
        cacheMoves
        cacheItems
        cacheTrainers
        cacheFields
        cacheMetadata
        @RXanimations       = load_data("Data/Animations.rxdata") if !@RXanimations
        @RXtilesets         = load_data("Data/tilesets.rxdata") if !@RXtilesets
        @RXevents           = load_data("Data/CommonEvents.rxdata") if !@RXevents
        @RXsystem           = load_data("Data/System.rxdata") if !@RXsystem
    end

    def cacheAnims
        @animations         = load_data("Data/PkmnAnimations.rxdata") if !@animations
    end

    def map_load(mapid)
        @cachedmaps = [] if !@cachedmaps
        if !@cachedmaps[mapid]
            puts "loading map",mapid
            @cachedmaps[mapid] = load_data(sprintf("Data/Map%03d.rxdata", mapid))
        end
        return @cachedmaps[mapid]
    end
end
$cache = Cache_Game.new if !$cache