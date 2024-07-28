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
        let category = b"Education";
        let image_url = b"";
        let linktree = b"";
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
            suifund::new_project_record_for_testing(name, description, category, image_url, linktree, x, telegram, discord, website, github, ratio, start_time_ms, time_interval, total_deposit_sui, amount_per_sui, 0, min_value_sui, max_value_sui, test_scenario::ctx(scenario))
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
        let category = b"Education";
        let image_url = b"";
        let linktree = b"";
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
            suifund::new_project_record_for_testing(name, description, category, image_url, linktree, x, telegram, discord, website, github, ratio, start_time_ms, time_interval, total_deposit_sui, amount_per_sui, 0, min_value_sui, max_value_sui, test_scenario::ctx(scenario))
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

    // #[test, expected_failure]
    // public fun test_project_end() {

    //     let sender = @0xABBA;
    //     let alice = @0xCAEE;

    //     let name = b"Fantastic Project";
    //     let description = b"This is a Fantastic Project";
    //     let category = b"Education";
    //     let image_url = b"";
    //     let linktree = b"";
    //     let x = b"";
    //     let telegram = b"";
    //     let discord = b"";
    //     let website = b"";
    //     let github = b"";
    //     let ratio: u64 = 1;
    //     let start_time_ms: u64 = 1000;
    //     let time_interval: u64 = 300_000_000;
    //     let total_deposit_sui: u64 = 1_000_000_000_000;
    //     let amount_per_sui: u64 = 1_000;
    //     let min_value_sui: u64 = 1_000_000_000;
    //     let max_value_sui: u64 = 0;

    //     let mut scenario_val = test_scenario::begin(sender);
    //     let scenario = &mut scenario_val;
    //     let mut clk = clock::create_for_testing(test_scenario::ctx(scenario));

    //     test_scenario::next_tx(scenario, sender);
    //     let mut project_record = {
    //         suifund::new_project_record_for_testing(name, description, category, image_url, linktree, x, telegram, discord, website, github, ratio, start_time_ms, time_interval, total_deposit_sui, amount_per_sui, 0, min_value_sui, max_value_sui, test_scenario::ctx(scenario))
    //     };

    //     clock::set_for_testing(&mut clk, 500_000_000);
    //     test_scenario::next_tx(scenario, alice);
    //     {
    //         let mut test_coin = coin::mint_for_testing<SUI>(min_value_sui, test_scenario::ctx(scenario));
    //         suifund::mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
    //         coin::burn_for_testing<SUI>(test_coin);
    //     };

    //     test_scenario::next_tx(scenario, sender);
    //     {
    //         suifund::drop_project_record_for_testing(project_record);
    //     };

    //     clock::destroy_for_testing(clk);
    //     test_scenario::end(scenario_val);
    // }

    #[test, expected_failure]
    public fun test_project_admin_cancel() {

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
            suifund::new_project_record_for_testing(name, description, category, image_url, linktree, x, telegram, discord, website, github, ratio, start_time_ms, time_interval, total_deposit_sui, amount_per_sui, 0, min_value_sui, max_value_sui, test_scenario::ctx(scenario))           
        };

        test_scenario::next_tx(scenario, sender);
        {
            let admin_cap = scenario.take_from_sender<suifund::AdminCap>();
            suifund::cancel_project_by_admin(&admin_cap, &mut project_record);
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
        let category = b"Education";
        let image_url = b"";
        let linktree = b"";
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
            suifund::new_project_record_for_testing(name, description, category, image_url, linktree, x, telegram, discord, website, github, ratio, start_time_ms, time_interval, total_deposit_sui, amount_per_sui, 0, min_value_sui, max_value_sui, test_scenario::ctx(scenario))           
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
    public fun test_burn_not_begin() {

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
        let mut clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        {
            suifund::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(20_000_000_000, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, name, description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, total_deposit_sui, ratio, amount_per_sui, 90, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 0, 1);
            test_scenario::return_shared(deploy_record);
        };

        clock::set_for_testing(&mut clk, 1000);
        test_scenario::next_tx(scenario, bob);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(100_000_000_000, test_scenario::ctx(scenario));
            let supporter_reward = suifund::do_mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(suifund::sr_amount(&supporter_reward) == 100 * amount_per_sui, 2);
            assert!(suifund::sr_balance_value(&supporter_reward) == 50_000_000_000, 3);
            transfer::public_transfer(supporter_reward, bob);
            assert!(suifund::project_participants_number(&project_record) == 1, 4);
            assert!(suifund::project_balance_value(&project_record) == 50_000_000_000, 5);
            assert!(suifund::project_current_supply(&project_record) == 100_000, 6);
            assert!(suifund::project_remain(&project_record) == 900_000, 7);
            assert!(suifund::project_total_supply(&project_record) == 1000_000, 8);
            assert!(suifund::project_total_transactions(&project_record) == 1, 9);
            assert!(coin::burn_for_testing(test_coin) == 0, 10);
            test_scenario::return_shared(project_record);
        };

        clock::increment_for_testing(&mut clk, 100_000_000);
        test_scenario::next_tx(scenario, bob);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let supporter_reward = test_scenario::take_from_sender<suifund::SupporterReward>(scenario);
            let burn_coin = suifund::do_burn(&mut project_record, supporter_reward, &clk, test_scenario::ctx(scenario));
            let receive_value = coin::burn_for_testing<SUI>(burn_coin);
            assert!(receive_value == 100_000_000_000, 12);
            assert!(suifund::project_current_supply(&project_record) == 0, 13);
            assert!(suifund::project_remain(&project_record) == 1000_000, 14);
            assert!(suifund::project_balance_value(&project_record) == 0, 15);
            test_scenario::return_shared(project_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure]
    public fun test_claim_not_begin() {

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
        let mut clk = clock::create_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, sender);
        {
            suifund::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(20_000_000_000, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, name, description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, total_deposit_sui, ratio, amount_per_sui, 90, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 0, 1);
            test_scenario::return_shared(deploy_record);
        };

        clock::set_for_testing(&mut clk, 1000);
        test_scenario::next_tx(scenario, bob);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(100_000_000_000, test_scenario::ctx(scenario));
            let supporter_reward = suifund::do_mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(suifund::sr_amount(&supporter_reward) == 100 * amount_per_sui, 2);
            assert!(suifund::sr_balance_value(&supporter_reward) == 50_000_000_000, 3);
            transfer::public_transfer(supporter_reward, bob);
            assert!(suifund::project_participants_number(&project_record) == 1, 4);
            assert!(suifund::project_balance_value(&project_record) == 50_000_000_000, 5);
            assert!(suifund::project_current_supply(&project_record) == 100_000, 6);
            assert!(suifund::project_remain(&project_record) == 900_000, 7);
            assert!(suifund::project_total_supply(&project_record) == 1000_000, 8);
            assert!(suifund::project_total_transactions(&project_record) == 1, 9);
            assert!(coin::burn_for_testing(test_coin) == 0, 10);
            test_scenario::return_shared(project_record);
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let project_admin_cap = test_scenario::take_from_sender<suifund::ProjectAdminCap>(scenario);
            let claim_coin = suifund::do_claim(&mut project_record, &project_admin_cap, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(claim_coin) == 0, 11);
            test_scenario::return_to_sender(scenario, project_admin_cap);
            test_scenario::return_shared(project_record);
        };

        clock::increment_for_testing(&mut clk, 100_000_000);
        test_scenario::next_tx(scenario, bob);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let supporter_reward = test_scenario::take_from_sender<suifund::SupporterReward>(scenario);
            let burn_coin = suifund::do_burn(&mut project_record, supporter_reward, &clk, test_scenario::ctx(scenario));
            let receive_value = coin::burn_for_testing<SUI>(burn_coin);
            assert!(receive_value == 100_000_000_000, 12);
            assert!(suifund::project_current_supply(&project_record) == 0, 13);
            assert!(suifund::project_remain(&project_record) == 1000_000, 14);
            assert!(suifund::project_balance_value(&project_record) == 0, 15);
            test_scenario::return_shared(project_record);
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
        let category = b"Education";
        let image_url = b"";
        let linktree = b"";
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
            suifund::new_project_record_for_testing(name, description, category, image_url, linktree, x, telegram, discord, website, github, ratio, start_time_ms, time_interval, total_deposit_sui, amount_per_sui, 0, min_value_sui, max_value_sui, test_scenario::ctx(scenario))           
        };

        clock::set_for_testing(&mut clk, 1000);
        test_scenario::next_tx(scenario, alice);
        {
            let mut test_coin = coin::mint_for_testing<SUI>(total_deposit_sui + 123, test_scenario::ctx(scenario));
            suifund::mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing<SUI>(test_coin) == 123, 1);
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut test_coin = coin::mint_for_testing<SUI>(min_value_sui + 123, test_scenario::ctx(scenario));
            suifund::mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing<SUI>(test_coin) == min_value_sui + 123, 2);
        };

        test_scenario::next_tx(scenario, sender);
        {
            suifund::drop_project_record_for_testing(project_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }

    #[test]
    #[lint_allow(self_transfer)]
    public fun test_whole_process_normal() {
        let sender = @0xABBA;
        let alice = @0xCAEE;
        let bob = @0xCAFE;
        let cindy = @0xE567;

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

        test_scenario::next_tx(scenario, alice);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(20_000_000_000, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, name, description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, total_deposit_sui, ratio, amount_per_sui, 0, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 0, 1);
            test_scenario::return_shared(deploy_record);
        };

        clock::set_for_testing(&mut clk, 1000);
        test_scenario::next_tx(scenario, bob);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(100_000_000_000, test_scenario::ctx(scenario));
            let supporter_reward = suifund::do_mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(suifund::sr_amount(&supporter_reward) == 100 * amount_per_sui, 2);
            assert!(suifund::sr_balance_value(&supporter_reward) == 50_000_000_000, 3);
            transfer::public_transfer(supporter_reward, bob);
            assert!(suifund::project_participants_number(&project_record) == 1, 4);
            assert!(suifund::project_balance_value(&project_record) == 50_000_000_000, 5);
            assert!(suifund::project_current_supply(&project_record) == 100_000, 6);
            assert!(suifund::project_remain(&project_record) == 900_000, 7);
            assert!(suifund::project_total_supply(&project_record) == 1000_000, 8);
            assert!(suifund::project_total_transactions(&project_record) == 1, 9);
            assert!(coin::burn_for_testing(test_coin) == 0, 10);
            test_scenario::return_shared(project_record);
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let project_admin_cap = test_scenario::take_from_sender<suifund::ProjectAdminCap>(scenario);
            let claim_coin = suifund::do_claim(&mut project_record, &project_admin_cap, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(claim_coin) == 0, 11);
            test_scenario::return_to_sender(scenario, project_admin_cap);
            test_scenario::return_shared(project_record);
        };

        clock::increment_for_testing(&mut clk, 100_000_000);
        test_scenario::next_tx(scenario, bob);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let supporter_reward = test_scenario::take_from_sender<suifund::SupporterReward>(scenario);
            let burn_coin = suifund::do_burn(&mut project_record, supporter_reward, &clk, test_scenario::ctx(scenario));
            let receive_value = coin::burn_for_testing<SUI>(burn_coin);
            assert!(receive_value == 90_000_000_000, 12);
            assert!(suifund::project_current_supply(&project_record) == 0, 13);
            assert!(suifund::project_remain(&project_record) == 900_000, 14);
            assert!(suifund::project_balance_value(&project_record) == 10_000_000_000, 15);
            test_scenario::return_shared(project_record);
        };

        clock::increment_for_testing(&mut clk, 150_000_000);
        test_scenario::next_tx(scenario, cindy);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(1000_000_000_000, test_scenario::ctx(scenario));
            let supporter_reward = suifund::do_mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 100_000_000_000, 16);
            // let burn_coin = suifund::do_burn(&mut project_record, supporter_reward, &clk, test_scenario::ctx(scenario));
            // assert!(coin::burn_for_testing<SUI>(burn_coin) == 675_000_000_000, 17);
            transfer::public_transfer(supporter_reward, cindy);
            test_scenario::return_shared(project_record);
        };

        test_scenario::next_tx(scenario, alice);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let project_admin_cap = test_scenario::take_from_sender<suifund::ProjectAdminCap>(scenario);
            let claim_coin = suifund::do_claim(&mut project_record, &project_admin_cap, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(claim_coin) == 235_000_000_000, 17);
            test_scenario::return_to_sender(scenario, project_admin_cap);
            test_scenario::return_shared(project_record);
        };

        clock::increment_for_testing(&mut clk, 500_000_000);
        test_scenario::next_tx(scenario, alice);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let project_admin_cap = test_scenario::take_from_sender<suifund::ProjectAdminCap>(scenario);
            let claim_coin = suifund::do_claim(&mut project_record, &project_admin_cap, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(claim_coin) == 225_000_000_000, 18);
            test_scenario::return_to_sender(scenario, project_admin_cap);
            test_scenario::return_shared(project_record);
        };

        test_scenario::next_tx(scenario, cindy);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let supporter_reward = test_scenario::take_from_sender<suifund::SupporterReward>(scenario);
            let burn_coin = suifund::do_burn(&mut project_record, supporter_reward, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing<SUI>(burn_coin) == 450_000_000_000, 19);
            test_scenario::return_shared(project_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }

    #[test]
    #[lint_allow(self_transfer)]
    public fun test_whole_process_cancel() {
        let sender = @0xABBA;
        let alice = @0xCAEE;
        let bob = @0xCAFE;
        let cindy = @0xE567;

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

        test_scenario::next_tx(scenario, alice);
        {
            let mut deploy_record = test_scenario::take_shared<suifund::DeployRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(20_000_000_000, test_scenario::ctx(scenario));
            suifund::deploy(&mut deploy_record, name, description, category, image_url, linktree, x, telegram, discord, website, github, start_time_ms, time_interval, total_deposit_sui, ratio, amount_per_sui, 0, min_value_sui, max_value_sui, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 0, 1);
            test_scenario::return_shared(deploy_record);
        };

        clock::set_for_testing(&mut clk, 1000);
        test_scenario::next_tx(scenario, bob);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(100_000_000_000, test_scenario::ctx(scenario));
            let supporter_reward = suifund::do_mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(suifund::sr_amount(&supporter_reward) == 100 * amount_per_sui, 2);
            assert!(suifund::sr_balance_value(&supporter_reward) == 50_000_000_000, 3);
            transfer::public_transfer(supporter_reward, bob);
            assert!(suifund::project_participants_number(&project_record) == 1, 4);
            assert!(suifund::project_balance_value(&project_record) == 50_000_000_000, 5);
            assert!(suifund::project_current_supply(&project_record) == 100_000, 6);
            assert!(suifund::project_remain(&project_record) == 900_000, 7);
            assert!(suifund::project_total_supply(&project_record) == 1000_000, 8);
            assert!(suifund::project_total_transactions(&project_record) == 1, 9);
            assert!(coin::burn_for_testing(test_coin) == 0, 10);
            test_scenario::return_shared(project_record);
        };

        clock::increment_for_testing(&mut clk, 100_000_000);
        test_scenario::next_tx(scenario, alice);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let project_admin_cap = test_scenario::take_from_sender<suifund::ProjectAdminCap>(scenario);
            let claim_coin = suifund::do_claim(&mut project_record, &project_admin_cap, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(claim_coin) == 10_000_000_000, 11);
            test_scenario::return_to_sender(scenario, project_admin_cap);
            test_scenario::return_shared(project_record);
        };

        test_scenario::next_tx(scenario, cindy);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let mut test_coin = coin::mint_for_testing<SUI>(1000_000_000_000, test_scenario::ctx(scenario));
            let supporter_reward = suifund::do_mint(&mut project_record, &mut test_coin, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing(test_coin) == 100_000_000_000, 12);
            let project_balance_value = suifund::project_balance_value(&project_record);
            assert!(project_balance_value == 450_000_000_000 + 40_000_000_000, 13);
            transfer::public_transfer(supporter_reward, cindy);
            test_scenario::return_shared(project_record);
        };

        test_scenario::next_tx(scenario, sender);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let admin_cap = scenario.take_from_sender<suifund::AdminCap>();
            suifund::cancel_project_by_admin(&admin_cap, &mut project_record);
            scenario.return_to_sender(admin_cap);
            test_scenario::return_shared(project_record);
        };

        clock::increment_for_testing(&mut clk, 123_000_000);
        test_scenario::next_tx(scenario, cindy);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let supporter_reward = test_scenario::take_from_sender<suifund::SupporterReward>(scenario);
            let burn_coin = suifund::do_burn(&mut project_record, supporter_reward, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing<SUI>(burn_coin) == 891_000_000_000, 14);
            test_scenario::return_shared(project_record);
        };

        test_scenario::next_tx(scenario, bob);
        {
            let mut project_record = test_scenario::take_shared<suifund::ProjectRecord>(scenario);
            let supporter_reward = test_scenario::take_from_sender<suifund::SupporterReward>(scenario);
            let burn_coin = suifund::do_burn(&mut project_record, supporter_reward, &clk, test_scenario::ctx(scenario));
            assert!(coin::burn_for_testing<SUI>(burn_coin) == 99_000_000_000, 15);
            test_scenario::return_shared(project_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);
    }
}