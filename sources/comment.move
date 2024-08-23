module suifund::comment {
    use std::string::{String, utf8};
    use sui::{clock::Clock, url::{Self, Url}, vec_set::{Self, VecSet}};

    public struct Comment has key, store {
        id: UID,
        reply: Option<ID>,
        creator: address,
        media_link: Url,
        content: String,
        timestamp: u64,
        // TODO: won't hold too many comments! may hit object size limit 256KB
        likes: VecSet<address>,
    }

    public fun new_comment(
        reply: Option<ID>,
        media_link: vector<u8>,
        content: vector<u8>,
        clock: &Clock,
        ctx: &mut TxContext,
    ): Comment {
        Comment {
            id: object::new(ctx),
            reply,
            creator: ctx.sender(),
            media_link: url::new_unsafe_from_bytes(media_link),
            content: utf8(content),
            timestamp: clock.timestamp_ms(),
            likes: vec_set::empty(),
        }
    }

    public fun drop_comment(comment: Comment) {
        let Comment { id, .. } = comment;
        id.delete()
    }

    public fun like_comment(comment: &mut Comment, ctx: &TxContext) {
        comment.likes.insert(ctx.sender());
    }

    public fun unlike_comment(comment: &mut Comment, ctx: &TxContext) {
        comment.likes.remove(&ctx.sender());
    }

    public fun like_count(comment: &Comment): u64 {
        comment.likes.size()
    }
}
