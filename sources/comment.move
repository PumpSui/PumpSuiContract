module suifund::comment {
    use std::string::{String, utf8};
    use sui::url::{Self, Url};
    use sui::clock::{Self, Clock};

    public struct Comment has key, store {
        id: UID,
        reply: Option<ID>,
        creator: address,
        media_link: Url,
        content: String,
        timestamp: u64,
    }

    public fun new_comment(
        reply: Option<ID>, 
        media_link: vector<u8>, 
        content: vector<u8>, 
        clk: &Clock,
        ctx: &mut TxContext
    ): Comment {
        Comment {
            id: object::new(ctx),
            reply,
            creator: ctx.sender(),
            media_link: url::new_unsafe_from_bytes(media_link),
            content: utf8(content),
            timestamp: clock::timestamp_ms(clk),
        }
    }


}