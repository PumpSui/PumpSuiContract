module suifund::utils_test {
    use suifund::utils;

    #[test]
    #[expected_failure]
    fun test_div_by_zero() {
        let res = utils::mul_div(100, 2, 0);
    }
}