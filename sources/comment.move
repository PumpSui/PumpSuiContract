module suifund::comment {
    use std::string::{String, utf8};
    use sui::url::{Self, Url};
    use sui::clock::{Self, Clock};
    use sui::vec_set::{Self, VecSet};

    public struct Comment has key, store {
        id: UID,
        reply: Option<ID>,
        creator: address,
        media_link: Url,
        content: String,
        timestamp: u64,
        likes: VecSet<address>,
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
            likes: vec_set::empty<address>(),
        }
    }

    public fun drop_comment(comment: Comment) {
        let Comment {
            id,
            reply: _,
            creator: _,
            media_link: _,
            content: _,
            timestamp: _,
            likes: _,
        } = comment;
        object::delete(id);
    }

    public fun like_comment(comment: &mut Comment, ctx: &TxContext) {
        vec_set::insert<address>(&mut comment.likes, ctx.sender());
    }

    public fun unlike_comment(comment: &mut Comment, ctx: &TxContext) {
        vec_set::remove<address>(&mut comment.likes, &ctx.sender());
    }

    public fun like_count(comment: &Comment): u64 {
        vec_set::size(&comment.likes)
    }
}