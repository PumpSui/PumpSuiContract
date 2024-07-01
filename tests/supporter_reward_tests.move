#[test_only]
module suifund::supporter_reward_tests {
    use sui::balance;
    use sui::url;
    use sui::sui::SUI;
    use suifund::suifund;

    #[test]
    fun test_split() {
        let mut ctx = tx_context::dummy();
        let name = std::ascii::string(b"Fantastic");
        let image_url = url::new_unsafe_from_bytes(b"");
        let balance = balance::create_for_testing<SUI>(1000_000_000_000);
        let mut sp_rwd = suifund::new_sp_rwd_for_testing(name, image_url, 1000, balance, 1000, 2000, &mut ctx);
        let sp_rwd_1 = suifund::do_split(&mut sp_rwd, 700, &mut ctx);
        assert!(suifund::sr_balance_value(&sp_rwd_1) == 700_000_000_000, 1);
        suifund::drop_sp_rwd_for_testing(sp_rwd);
        suifund::drop_sp_rwd_for_testing(sp_rwd_1);
    }

    #[test, expected_failure]
    fun test_zero_split() {
        let mut ctx = tx_context::dummy();
        let name = std::ascii::string(b"Fantastic");
        let image_url = url::new_unsafe_from_bytes(b"");
        let balance = balance::create_for_testing<SUI>(1000_000_000_000);
        let mut sp_rwd = suifund::new_sp_rwd_for_testing(name, image_url, 1000, balance, 1000, 2000, &mut ctx);
        let sp_rwd_1 = suifund::do_split(&mut sp_rwd, 0, &mut ctx);
        assert!(suifund::sr_balance_value(&sp_rwd_1) == 0, 1);
        suifund::drop_sp_rwd_for_testing(sp_rwd);
        suifund::drop_sp_rwd_for_testing(sp_rwd_1);
    }

    #[test, expected_failure]
    fun test_over_split() {
        let mut ctx = tx_context::dummy();
        let name = std::ascii::string(b"Fantastic");
        let image_url = url::new_unsafe_from_bytes(b"");
        let balance = balance::create_for_testing<SUI>(1000_000_000_000);
        let mut sp_rwd = suifund::new_sp_rwd_for_testing(name, image_url, 1000, balance, 1000, 2000, &mut ctx);
        let sp_rwd_1 = suifund::do_split(&mut sp_rwd, 2000, &mut ctx);
        assert!(suifund::sr_balance_value(&sp_rwd_1) == 2000_000_000_000, 1);
        suifund::drop_sp_rwd_for_testing(sp_rwd);
        suifund::drop_sp_rwd_for_testing(sp_rwd_1);
    }

    #[test]
    fun test_merge() {
        let mut ctx = tx_context::dummy();
        let name = std::ascii::string(b"Fantastic");
        let image_url = url::new_unsafe_from_bytes(b"");
        let balance_1 = balance::create_for_testing<SUI>(1000_000_000_000);
        let balance_2 = balance::create_for_testing<SUI>(1000_000_000_000);
        let mut sp_rwd = suifund::new_sp_rwd_for_testing(name, image_url, 1000, balance_1, 1000, 2000, &mut ctx);
        let sp_rwd_1 = suifund::new_sp_rwd_for_testing(name, image_url, 1000, balance_2, 1000, 2000, &mut ctx);
        suifund::do_merge(&mut sp_rwd, sp_rwd_1);
        assert!(suifund::sr_balance_value(&sp_rwd) == 2000_000_000_000, 1);
        assert!(suifund::sr_amount(&sp_rwd) == 2000, 2);
        suifund::drop_sp_rwd_for_testing(sp_rwd);
    }

    #[test, expected_failure]
    fun test_merge_different_project() {
        let mut ctx = tx_context::dummy();
        let name_1 = std::ascii::string(b"Fantastic");
        let name_2 = std::ascii::string(b"Not Fantastic");
        let image_url = url::new_unsafe_from_bytes(b"");
        let balance_1 = balance::create_for_testing<SUI>(1000_000_000_000);
        let balance_2 = balance::create_for_testing<SUI>(1000_000_000_000);
        let mut sp_rwd = suifund::new_sp_rwd_for_testing(name_1, image_url, 1000, balance_1, 1000, 2000, &mut ctx);
        let sp_rwd_1 = suifund::new_sp_rwd_for_testing(name_2, image_url, 1000, balance_2, 1000, 2000, &mut ctx);
        suifund::do_merge(&mut sp_rwd, sp_rwd_1);
        assert!(suifund::sr_balance_value(&sp_rwd) == 2000_000_000_000, 1);
        assert!(suifund::sr_amount(&sp_rwd) == 2000, 2);
        suifund::drop_sp_rwd_for_testing(sp_rwd);
    }
}