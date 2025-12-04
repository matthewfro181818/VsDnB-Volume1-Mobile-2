package data.song;

import haxe.Json;
import json2object.JsonWriter;

// ------------------------------------------------------------
// SONG METADATA
// ------------------------------------------------------------

class SongMetadata {
    /** Metadata version */
    public var version:String;

    /** Song readable name */
    public var songName:String;

    /** Credits */
    @:default([]) public var composers:Array<String>;
    @:default([]) public var artists:Array<String>;
    @:default([]) public var charters:Array<String>;
    @:default([]) public var coders:Array<String>;

    /** Variants */
    @:default([]) @:optional public var variations:Array<String>;

    /** Characters / stage */
    @:default("stage") public var stage:String;
    @:default("bf") public var player:String;
    @:default("dave") public var opponent:String;

    @:alias("gf") @:default("gf")
    public var girlfriend:String;

    /** BPM/time signature changes */
    public var timeChanges:Array<SongTimeChange> = [];

    public function new(
        songName:String,
        composers:Array<String>,
        artists:Array<String>,
        charters:Array<String>,
        coders:Array<String>
    ) {
        this.version = SongRegistry.METADATA_VERSION;
        this.songName = songName;
        this.composers = composers;
        this.artists = artists;
        this.charters = charters;
        this.coders = coders;
    }

    public function toString():String {
        return '[SongMetadata] ${songName}';
    }

    public function serialize():String {
        var writer = new JsonWriter<SongMetadata>();
        writer.ignoreNullOptionals = true;
        return writer.write(this, "  ");
    }
}

// ------------------------------------------------------------
// SONG CHART DATA
// ------------------------------------------------------------

class SongChartData {
    public var version:String;
    @:default(1) public var speed:Float;
    @:default([]) public var notes:Array<SongSection>;

    public function new(speed:Float, notes:Array<SongSection>) {
        this.version = SongRegistry.CHART_DATA_VERSION;
        this.speed = speed;
        this.notes = notes;
    }

    public function serialize():String {
        var writer = new JsonWriter<SongChartData>(true);
        return writer.write(this, "  ");
    }
}

// ------------------------------------------------------------
// NOTE DATA
// ------------------------------------------------------------

@:forward(time, direction, length, type, noteStyle, getDirection)
abstract SongNoteData(SongNoteDataRaw) from SongNoteDataRaw to SongNoteDataRaw {
    public function new(time:Float, direction:Int, length:Float = 0.0, type:String = "", style:String = "normal") {
        this = new SongNoteDataRaw(time, direction, length, type, style);
    }

    @:op(A == B)
    public function eq(other:SongNoteData):Bool {
        return this.time == other.time
            && this.direction == other.direction
            && this.length == other.length
            && this.type == other.type
            && this.noteStyle == other.noteStyle;
    }

    @:op(A != B)
    public function neq(other:SongNoteData):Bool {
        return !eq(other);
    }

    @:op(A > B)
    public function gt(other:SongNoteData):Bool return this.time > other.time;

    @:op(A < B)
    public function lt(other:SongNoteData):Bool return this.time < other.time;

    @:op(A >= B)
    public function ge(other:SongNoteData):Bool return this.time >= other.time;

    @:op(A <= B)
    public function le(other:SongNoteData):Bool return this.time <= other.time;
}

class SongNoteDataRaw {
    @:default(0.0) public var time:Float;
    @:default(0)   public var direction:Int;
    @:default(0)   public var length:Float;
    @:default("")  @:optional public var type:String;
    @:alias("style") @:default("normal") public var noteStyle:String;

    public function new(time:Float, direction:Int, length:Float, type:String, style:String) {
        this.time = time;
        this.direction = direction;
        this.length = length;
        this.type = type;
        this.noteStyle = style;
    }

    public function getDirection():Int return direction % 4;

    public function toString():String {
        return 'Note(time=$time dir=$direction len=$length type=$type)';
    }
}

// ------------------------------------------------------------
// TIME CHANGE
// ------------------------------------------------------------

@:forward(time, bpm, numerator, denominator, stepTime, beatTime, measureTime)
abstract SongTimeChange(SongTimeChangeRaw)
    from SongTimeChangeRaw
    to SongTimeChangeRaw 
{
    public function new(time:Float, bpm:Float, numerator:Int = 4, denominator:Int = 4) {
        this = new SongTimeChangeRaw(time, bpm, numerator, denominator);
    }

    @:op(A == B)
    public function eq(other:SongTimeChange):Bool {
        return this.time == other.time
            && this.bpm == other.bpm
            && this.numerator == other.numerator
            && this.denominator == other.denominator;
    }

    @:op(A != B)
    public function neq(other:SongTimeChange):Bool return !eq(other);

    @:op(A > B)
    public function gt(other:SongTimeChange):Bool return this.time > other.time;

    @:op(A < B)
    public function lt(other:SongTimeChange):Bool return this.time < other.time;

    @:op(A >= B)
    public function ge(other:SongTimeChange):Bool return this.time >= other.time;

    @:op(A <= B)
    public function le(other:SongTimeChange):Bool return this.time <= other.time;
}

class SongTimeChangeRaw {
    @:default(0.0) public var time:Float;
    @:default(100) public var bpm:Float;
    @:default(4) public var numerator:Int;
    @:default(4) public var denominator:Int;

    @:jignored public var stepTime:Float = 0;
    @:jignored public var beatTime:Float = 0;
    @:jignored public var measureTime:Float = 0;

    public function new(time:Float, bpm:Float, numerator:Int, denominator:Int) {
        this.time = time;
        this.bpm = bpm;
        this.numerator = numerator;
        this.denominator = denominator;
    }

    public function toString():String {
        return 'TimeChange(${time}ms @ ${bpm}bpm ${numerator}/${denominator})';
    }
}

// ------------------------------------------------------------
// SONG SECTION
// ------------------------------------------------------------

typedef SongSection = {
    notes:Array<SongNoteData>,
    mustHitSection:Bool
};

// ------------------------------------------------------------
// SONG MUSIC DATA
// ------------------------------------------------------------

class SongMusicData {
    public var version:String;
    public var name:String;
    public var musicPath:String;

    public var composers:Array<String>;
    public var variations:Array<String>;
    public var timeChanges:Array<SongTimeChange>;

    public function toString():String {
        return 'SongMusicData($name v:$version)';
    }
}
