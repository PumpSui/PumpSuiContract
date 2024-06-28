#[test_only]
module suifund::utils_test {
    use suifund::utils;

    #[test, expected_failure]
    fun test_div_by_zero() {
        let _res = utils::mul_div(100, 2, 0);
    }

    #[test]
    fun test_mul_div() {
        assert!(utils::mul_div(100, 2, 5) == 40, 1);
        assert!(utils::mul_div(256_000, 6, 3) == 512_000, 1);
    }

    #[test]
    fun test_get_remain_value() {
        let remain_1 = utils::get_remain_value(1000, 100, 200, 150);
        assert!(remain_1 == 500, 1);
        let remain_2 = utils::get_remain_value(1000, 100, 200, 175);
        assert!(remain_2 == 250, 2);
        let remain_3 = utils::get_remain_value(1000, 100, 200, 250);
        assert!(remain_3 == 0, 3);
        let remain_4 = utils::get_remain_value(1000, 100, 200, 50);
        assert!(remain_4 == 1000, 4);
    }
}