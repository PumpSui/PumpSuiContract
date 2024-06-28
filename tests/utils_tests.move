module suifund::utils_test {
    use suifund::utils;

    #[test]
    #[expected_failure]
    fun test_div_by_zero() {
        let _res = utils::mul_div(100, 2, 0);
    }

    #[test]
    fun test_mul_div() {
        assert!(utils::mul_div(100, 2, 5) == 40, 1);
        assert!(utils::mul_div(256_000, 6, 3) == 512_000, 1);
    }
}