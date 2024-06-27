module suifund::utils {

    public fun mul_div(x: u64, y: u64, z: u64): u64 {
        (((x as u128) * (y as u128) / (z as u128)) as u64)
    }

    public fun get_remain_value(init_value: u64, start_time: u64, end_time: u64, now_ms: u64): u64 {
        if (now_ms >= end_time) {
            0
        } else {
            mul_div(init_value, (end_time - now_ms), (end_time - start_time))
        }
    }

}