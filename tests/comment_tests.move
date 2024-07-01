#[test_only]
module suifund::comment_tests {
    use sui::clock;
    use suifund::comment;

    #[test]
    fun test_comment() {
        let mut ctx = tx_context::dummy();
        let clk = clock::create_for_testing(&mut ctx);
        let mut comment_1 = comment::new_comment(option::none<ID>(), b"empty", b"test", &clk, &mut ctx);
        let comment_2 = comment::new_comment(option::some<ID>(object::id(&comment_1)), b"https://image.jpeg", b"nothing", &clk, &mut ctx);
        assert!(comment::like_count(&comment_1) == 0, 1);
        comment::like_comment(&mut comment_1, &ctx);
        assert!(comment::like_count(&comment_1) == 1, 2);
        comment::unlike_comment(&mut comment_1, &ctx);
        assert!(comment::like_count(&comment_1) == 0, 3);
        comment::drop_comment(comment_1);
        comment::drop_comment(comment_2);
        clock::destroy_for_testing(clk);
    }
}