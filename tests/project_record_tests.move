#[test_only]
module suifund::project_record_tests {
    use sui::clock;
    use sui::test_scenario;
    use suifund::suifund;

    #[test]
    #[lint_allow(self_transfer)]
    public fun test_whole_process() {

        let sender = @0xABBA;
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
        let project_record = {
            suifund::new_project_record_for_testing(name, description, image_url, x, telegram, discord, website, github, ratio, start_time_ms, time_interval, total_deposit_sui, amount_per_sui, min_value_sui, max_value_sui, test_scenario::ctx(scenario))
        };

        test_scenario::next_tx(scenario, sender);
        {
            suifund::drop_project_record_for_testing(project_record);
        };

        clock::destroy_for_testing(clk);
        test_scenario::end(scenario_val);

    }

}