#[test_only]
module suifund::deploy_record_tests {
    use sui::coin;
    use sui::clock;
    use sui::sui::SUI;
    use sui::test_scenario;
    use suifund::suifund;

    #[test, expected_failure]
    public fun test_deploy_same_name_twice() {
        let sender = @0xABBA;
        let alice = @0xCAEE;
        let bob = @0xCAFE;

        let name = b"Fantastic Project";
        let description = b"This is a Fantastic Project";
        let category = b"Education";
        let image_url = b"";
        let linktree = b"";
        let x = b"";
        let telegram = b"";
        let discord = b"";
        let website = b"";
        let github = b"";
        let ratio: u64 = 50;
        let start_time_ms: u64 = 1000;
        let time_interval: u64 = 500_000_000;
        let total_deposit_sui: u64 = 1_000_000_000_000;
        let amount_per_sui: u64 = 1_000;
        let min_value_sui: u64 = 1_000_000_000;
        let max_value_sui: u64 = 0;

        let mut scenario_val = test_scenario::begin(sender);
        let scenario = &mut scenario_val;
        let clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        {
            suifund::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(20_000_000_000, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, name, description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, total_deposit_sui, ratio, amount_per_sui, 0, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 0, 1);
            test_scenario::return_shared(deploy_record);
        };

        test_scenario::next_tx(scenario, bob);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(20_000_000_000, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, name, description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, total_deposit_sui, ratio, amount_per_sui, 0, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 0, 1);
            test_scenario::return_shared(deploy_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure]
    public fun test_deploy_invalid_start_time() {
        let sender = @0xABBA;
        let alice = @0xCAEE;

        let name = b"Fantastic Project";
        let description = b"This is a Fantastic Project";
        let category = b"Education";
        let image_url = b"";
        let linktree = b"";
        let x = b"";
        let telegram = b"";
        let discord = b"";
        let website = b"";
        let github = b"";
        let ratio: u64 = 50;
        let start_time_ms: u64 = 1000;
        let time_interval: u64 = 500_000_000;
        let total_deposit_sui: u64 = 1_000_000_000_000;
        let amount_per_sui: u64 = 1_000;
        let min_value_sui: u64 = 1_000_000_000;
        let max_value_sui: u64 = 0;

        let mut scenario_val = test_scenario::begin(sender);
        let scenario = &mut scenario_val;
        let mut clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        {
            suifund::init_for_testing(test_scenario::ctx(scenario));
        };

        clock::increment_for_testing(&mut clk, 100_000_000);
        test_scenario::next_tx(scenario, alice);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(20_000_000_000, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, name, description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, total_deposit_sui, ratio, amount_per_sui, 0, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 0, 1);
            test_scenario::return_shared(deploy_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }


    #[test, expected_failure]
    public fun test_deploy_invalid_time_interval() {
        let sender = @0xABBA;
        let alice = @0xCAEE;

        let name = b"Fantastic Project";
        let description = b"This is a Fantastic Project";
        let category = b"Education";
        let image_url = b"";
        let linktree = b"";
        let x = b"";
        let telegram = b"";
        let discord = b"";
        let website = b"";
        let github = b"";
        let ratio: u64 = 50;
        let start_time_ms: u64 = 1000;
        let time_interval: u64 = 259_200_000 - 1;
        let total_deposit_sui: u64 = 1_000_000_000_000;
        let amount_per_sui: u64 = 1_000;
        let min_value_sui: u64 = 1_000_000_000;
        let max_value_sui: u64 = 0;

        let mut scenario_val = test_scenario::begin(sender);
        let scenario = &mut scenario_val;
        let clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        {
            suifund::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(20_000_000_000, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, name, description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, total_deposit_sui, ratio, amount_per_sui, 0, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 0, 1);
            test_scenario::return_shared(deploy_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure]
    public fun test_deploy_ratio() {
        let sender = @0xABBA;
        let alice = @0xCAEE;

        let name = b"Fantastic Project";
        let description = b"This is a Fantastic Project";
        let category = b"Education";
        let image_url = b"";
        let linktree = b"";
        let x = b"";
        let telegram = b"";
        let discord = b"";
        let website = b"";
        let github = b"";
        let ratio: u64 = 101;
        let start_time_ms: u64 = 1000;
        let time_interval: u64 = 259_200_000 + 1;
        let total_deposit_sui: u64 = 1_000_000_000_000;
        let amount_per_sui: u64 = 1_000;
        let min_value_sui: u64 = 1_000_000_000;
        let max_value_sui: u64 = 0;

        let mut scenario_val = test_scenario::begin(sender);
        let scenario = &mut scenario_val;
        let clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        {
            suifund::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(20_000_000_000, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, name, description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, total_deposit_sui, ratio, amount_per_sui, 0, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 0, 1);
            test_scenario::return_shared(deploy_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure]
    public fun test_deploy_too_little_min_value() {
        let sender = @0xABBA;
        let alice = @0xCAEE;

        let name = b"Fantastic Project";
        let description = b"This is a Fantastic Project";
        let category = b"Education";
        let image_url = b"";
        let linktree = b"";
        let x = b"";
        let telegram = b"";
        let discord = b"";
        let website = b"";
        let github = b"";
        let ratio: u64 = 100;
        let start_time_ms: u64 = 1000;
        let time_interval: u64 = 259_200_000 + 1;
        let total_deposit_sui: u64 = 1_000_000_000_000;
        let amount_per_sui: u64 = 1_000;
        let min_value_sui: u64 = 900_000_000;
        let max_value_sui: u64 = 0;

        let mut scenario_val = test_scenario::begin(sender);
        let scenario = &mut scenario_val;
        let clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        {
            suifund::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(20_000_000_000, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, name, description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, total_deposit_sui, ratio, amount_per_sui, 0, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 0, 1);
            test_scenario::return_shared(deploy_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure]
    public fun test_deploy_invalid_value_range() {
        let sender = @0xABBA;
        let alice = @0xCAEE;

        let name = b"Fantastic Project";
        let description = b"This is a Fantastic Project";
        let category = b"Education";
        let image_url = b"";
        let linktree = b"";
        let x = b"";
        let telegram = b"";
        let discord = b"";
        let website = b"";
        let github = b"";
        let ratio: u64 = 100;
        let start_time_ms: u64 = 1000;
        let time_interval: u64 = 259_200_000 + 1;
        let total_deposit_sui: u64 = 1_000_000_000_000;
        let amount_per_sui: u64 = 1_000;
        let min_value_sui: u64 = 10_000_000_000;
        let max_value_sui: u64 = 9_000_000_000;

        let mut scenario_val = test_scenario::begin(sender);
        let scenario = &mut scenario_val;
        let clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        {
            suifund::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(20_000_000_000, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, name, description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, total_deposit_sui, ratio, amount_per_sui, 0, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 0, 1);
            test_scenario::return_shared(deploy_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }

    #[test]
    public fun test_deploy_fee() {
        let sender = @0xABBA;
        let alice = @0xCAEE;
        let bob = @0xCAFE;
        let cindy = @0xFEFE;

        let name = b"Fantastic Project";
        let description = b"This is a Fantastic Project";
        let category = b"Education";
        let image_url = b"";
        let linktree = b"";
        let x = b"";
        let telegram = b"";
        let discord = b"";
        let website = b"";
        let github = b"";
        let ratio: u64 = 100;
        let start_time_ms: u64 = 1000;
        let time_interval: u64 = 259_200_000 + 1;
        let total_deposit_sui: u64 = 1_000_000_000_000;
        let amount_per_sui: u64 = 1_000;
        let min_value_sui: u64 = 10_000_000_000;
        let max_value_sui: u64 = 0;

        let mut scenario_val = test_scenario::begin(sender);
        let scenario = &mut scenario_val;
        let clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        {
            suifund::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(20_000_000_100, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, name, description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, total_deposit_sui, ratio, amount_per_sui, 0, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 100, 1);
            test_scenario::return_shared(deploy_record);
        };

        test_scenario::next_tx(scenario, bob);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(50_000_000_123, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, b"Bob homepage", description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, 5_000_000_000_000, ratio, amount_per_sui, 0, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 123, 2);
            test_scenario::return_shared(deploy_record);
        };

        test_scenario::next_tx(scenario, sender);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let admin_cap = scenario.take_from_sender<suifund::AdminCap>();
            suifund::set_ratio(&admin_cap, &mut deploy_record, 3);
            scenario.return_to_sender(admin_cap);
            test_scenario::return_shared(deploy_record);
        };

        test_scenario::next_tx(scenario, cindy);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(250_000_000_567, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, b"Cindy homepage", description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, 5_000_000_000_000, ratio, amount_per_sui, 0, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 100_000_000_567, 4);
            test_scenario::return_shared(deploy_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }
}
