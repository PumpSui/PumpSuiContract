#[test_only]
module suifund::project_record_tests {
    use sui::coin;
    use sui::clock;
    use sui::sui::SUI;
    use sui::test_scenario;
    use suifund::suifund;

    #[test, expected_failure]
    public fun test_not_start() {

        let sender = @0xABBA;
        let alice = @0xCAEE;

        let name = b"Fantastic Project";
        let description = b"This is a Fantastic Project";
        let image_url = b"";
        let x = b"";
        let telegram = b"";
        let discord = b"";
        let website = b"";
        let github = b"";
        let ratio: u64 = 1;
        let start_time_ms: u64 = 1000;
        let time_interval: u64 = 300_000_000;
        let total_deposit_sui: u64 = 1_000_000_000_000;
        let amount_per_sui: u64 = 1_000;
        let min_value_sui: u64 = 1_000_000_000;
        let max_value_sui: u64 = 0;

        let mut scenario_val = test_scenario::begin(sender);
        let scenario = &mut scenario_val;
        let clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        let mut project_record = {
            suifund::new_project_record_for_testing(name, description, image_url, x, telegram, discord, website, github, ratio, start_time_ms, time_interval, total_deposit_sui, amount_per_sui, min_value_sui, max_value_sui, test_scenario::ctx(scenario))
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut test_coin = coin::mint_for_testing<SUI>(min_value_sui, test_scenario::ctx(scenario));
            suifund::mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            coin::burn_for_testing<SUI>(test_coin);
        };

        test_scenario::next_tx(scenario, sender);
        {
            suifund::drop_project_record_for_testing(project_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure]
    public fun test_too_little() {

        let sender = @0xABBA;
        let alice = @0xCAEE;

        let name = b"Fantastic Project";
        let description = b"This is a Fantastic Project";
        let image_url = b"";
        let x = b"";
        let telegram = b"";
        let discord = b"";
        let website = b"";
        let github = b"";
        let ratio: u64 = 1;
        let start_time_ms: u64 = 1000;
        let time_interval: u64 = 300_000_000;
        let total_deposit_sui: u64 = 1_000_000_000_000;
        let amount_per_sui: u64 = 1_000;
        let min_value_sui: u64 = 1_000_000_000;
        let max_value_sui: u64 = 0;

        let mut scenario_val = test_scenario::begin(sender);
        let scenario = &mut scenario_val;
        let mut clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        let mut project_record = {
            suifund::new_project_record_for_testing(name, description, image_url, x, telegram, discord, website, github, ratio, start_time_ms, time_interval, total_deposit_sui, amount_per_sui, min_value_sui, max_value_sui, test_scenario::ctx(scenario))
        };

        clock::set_for_testing(&mut clk, 1000);
        test_scenario::next_tx(scenario, alice);
        {
            let mut test_coin = coin::mint_for_testing<SUI>(min_value_sui - 1, test_scenario::ctx(scenario));
            suifund::mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            coin::burn_for_testing<SUI>(test_coin);
        };

        test_scenario::next_tx(scenario, sender);
        {
            suifund::drop_project_record_for_testing(project_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure]
    public fun test_project_end() {

        let sender = @0xABBA;
        let alice = @0xCAEE;

        let name = b"Fantastic Project";
        let description = b"This is a Fantastic Project";
        let image_url = b"";
        let x = b"";
        let telegram = b"";
        let discord = b"";
        let website = b"";
        let github = b"";
        let ratio: u64 = 1;
        let start_time_ms: u64 = 1000;
        let time_interval: u64 = 300_000_000;
        let total_deposit_sui: u64 = 1_000_000_000_000;
        let amount_per_sui: u64 = 1_000;
        let min_value_sui: u64 = 1_000_000_000;
        let max_value_sui: u64 = 0;

        let mut scenario_val = test_scenario::begin(sender);
        let scenario = &mut scenario_val;
        let mut clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        let mut project_record = {
            suifund::new_project_record_for_testing(name, description, image_url, x, telegram, discord, website, github, ratio, start_time_ms, time_interval, total_deposit_sui, amount_per_sui, min_value_sui, max_value_sui, test_scenario::ctx(scenario))
        };

        clock::set_for_testing(&mut clk, 500_000_000);
        test_scenario::next_tx(scenario, alice);
        {
            let mut test_coin = coin::mint_for_testing<SUI>(min_value_sui, test_scenario::ctx(scenario));
            suifund::mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            coin::burn_for_testing<SUI>(test_coin);
        };

        test_scenario::next_tx(scenario, sender);
        {
            suifund::drop_project_record_for_testing(project_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure]
    public fun test_project_cancel() {

        let sender = @0xABBA;
        let alice = @0xCAEE;

        let name = b"Fantastic Project";
        let description = b"This is a Fantastic Project";
        let image_url = b"";
        let x = b"";
        let telegram = b"";
        let discord = b"";
        let website = b"";
        let github = b"";
        let ratio: u64 = 1;
        let start_time_ms: u64 = 1000;
        let time_interval: u64 = 300_000_000;
        let total_deposit_sui: u64 = 1_000_000_000_000;
        let amount_per_sui: u64 = 1_000;
        let min_value_sui: u64 = 1_000_000_000;
        let max_value_sui: u64 = 0;

        let mut scenario_val = test_scenario::begin(sender);
        let scenario = &mut scenario_val;
        let mut clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        let mut project_record = {
            suifund::init_for_testing(test_scenario::ctx(scenario));
            suifund::new_project_record_for_testing(name, description, image_url, x, telegram, discord, website, github, ratio, start_time_ms, time_interval, total_deposit_sui, amount_per_sui, min_value_sui, max_value_sui, test_scenario::ctx(scenario))           
        };

        test_scenario::next_tx(scenario, sender);
        {
            let admin_cap = scenario.take_from_sender<suifund::AdminCap>();
            suifund::cancel_project(&admin_cap, &mut project_record);
            scenario.return_to_sender(admin_cap);
        };

        clock::set_for_testing(&mut clk, 1000);
        test_scenario::next_tx(scenario, alice);
        {
            let mut test_coin = coin::mint_for_testing<SUI>(min_value_sui, test_scenario::ctx(scenario));
            suifund::mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            coin::burn_for_testing<SUI>(test_coin);
        };

        test_scenario::next_tx(scenario, sender);
        {
            suifund::drop_project_record_for_testing(project_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure]
    public fun test_over_max() {

        let sender = @0xABBA;
        let alice = @0xCAEE;

        let name = b"Fantastic Project";
        let description = b"This is a Fantastic Project";
        let image_url = b"";
        let x = b"";
        let telegram = b"";
        let discord = b"";
        let website = b"";
        let github = b"";
        let ratio: u64 = 1;
        let start_time_ms: u64 = 1000;
        let time_interval: u64 = 300_000_000;
        let total_deposit_sui: u64 = 1_000_000_000_000;
        let amount_per_sui: u64 = 1_000;
        let min_value_sui: u64 = 1_000_000_000;
        let max_value_sui: u64 = 100_000_000_000;

        let mut scenario_val = test_scenario::begin(sender);
        let scenario = &mut scenario_val;
        let mut clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        let mut project_record = {
            suifund::init_for_testing(test_scenario::ctx(scenario));
            suifund::new_project_record_for_testing(name, description, image_url, x, telegram, discord, website, github, ratio, start_time_ms, time_interval, total_deposit_sui, amount_per_sui, min_value_sui, max_value_sui, test_scenario::ctx(scenario))           
        };

        clock::set_for_testing(&mut clk, 1000);
        test_scenario::next_tx(scenario, alice);
        {
            let mut test_coin = coin::mint_for_testing<SUI>(max_value_sui + 123, test_scenario::ctx(scenario));
            suifund::mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing<SUI>(test_coin) == 123, 1);
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut test_coin = coin::mint_for_testing<SUI>(1, test_scenario::ctx(scenario));
            suifund::mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            coin::burn_for_testing<SUI>(test_coin);
        };

        test_scenario::next_tx(scenario, sender);
        {
            suifund::drop_project_record_for_testing(project_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }

    #[test]
    public fun test_over_total() {

        let sender = @0xABBA;
        let alice = @0xCAEE;

        let name = b"Fantastic Project";
        let description = b"This is a Fantastic Project";
        let image_url = b"";
        let x = b"";
        let telegram = b"";
        let discord = b"";
        let website = b"";
        let github = b"";
        let ratio: u64 = 1;
        let start_time_ms: u64 = 1000;
        let time_interval: u64 = 300_000_000;
        let total_deposit_sui: u64 = 1_000_000_000_000;
        let amount_per_sui: u64 = 1_000;
        let min_value_sui: u64 = 1_000_000_000;
        let max_value_sui: u64 = 0;

        let mut scenario_val = test_scenario::begin(sender);
        let scenario = &mut scenario_val;
        let mut clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        let mut project_record = {
            suifund::init_for_testing(test_scenario::ctx(scenario));
            suifund::new_project_record_for_testing(name, description, image_url, x, telegram, discord, website, github, ratio, start_time_ms, time_interval, total_deposit_sui, amount_per_sui, min_value_sui, max_value_sui, test_scenario::ctx(scenario))           
        };

        clock::set_for_testing(&mut clk, 1000);
        test_scenario::next_tx(scenario, alice);
        {
            let mut test_coin = coin::mint_for_testing<SUI>(total_deposit_sui + 123, test_scenario::ctx(scenario));
            suifund::mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing<SUI>(test_coin) == 123, 1);
        };

        test_scenario::next_tx(scenario, sender);
        {
            suifund::drop_project_record_for_testing(project_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }
}