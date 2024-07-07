module suifund::swap {
    use std::type_name;
    use sui::coin::{Self, Coin, CoinMetadata, TreasuryCap};
    use suifund::suifund::{Self, ProjectRecord, ProjectAdminCap, SupporterReward};

    const EAlreadyInit: u64 = 0;
    const EInvalidMetaData: u64 = 1;
    const EInvalidTreasuryCap: u64 = 2;
    const ENotInit: u64 = 3;
    const ENotSameProject: u64 = 4;
    const EZeroCoin: u64 = 5;

    public entry fun init_swap<T>(
        project_record: &mut ProjectRecord,
        project_admin_cap: &ProjectAdminCap,
        treasury_cap: TreasuryCap<T>,
        coin_metadata: CoinMetadata<T>,
    ) {
        assert!(!suifund::exists_in_project<std::ascii::String>(project_record, std::ascii::string(b"coin_type")), EAlreadyInit);
        suifund::check_project_cap(project_record, project_admin_cap);
        assert!(coin::get_decimals<T>(&coin_metadata) == 0, EInvalidMetaData);
        assert!(coin::total_supply<T>(&treasury_cap) == 0, EInvalidTreasuryCap);

        let coin_type = type_name::into_string(type_name::get_with_original_ids<T>());
        suifund::add_df_in_project<std::ascii::String, std::ascii::String>(project_record, std::ascii::string(b"coin_type"), coin_type);
        suifund::add_df_in_project<std::ascii::String, TreasuryCap<T>>(project_record, std::ascii::string(b"treasury"), treasury_cap);
        suifund::add_df_in_project<std::ascii::String, CoinMetadata<T>>(project_record, std::ascii::string(b"metadata"), coin_metadata);
        suifund::add_df_in_project<std::ascii::String, vector<SupporterReward>>(project_record, std::ascii::string(b"storage_sr"), vector::empty<SupporterReward>());
    }

    public fun sr_to_coin<T>(
        project_record: &mut ProjectRecord,
        supporter_reward: SupporterReward,
        ctx: &mut TxContext
    ): Coin<T> {
        assert!(suifund::exists_in_project<std::ascii::String>(project_record, std::ascii::string(b"coin_type")), ENotInit);
        assert!(suifund::project_name(project_record) == suifund::sr_name(&supporter_reward), ENotSameProject);
        let value = suifund::sr_amount(&supporter_reward);
        let storage_sr = suifund::borrow_mut_in_project<std::ascii::String, vector<SupporterReward>>(project_record, std::ascii::string(b"storage_sr"));

        if (vector::is_empty<SupporterReward>(storage_sr)) {
            vector::push_back<SupporterReward>(storage_sr, supporter_reward);
        } else {
            let sr_mut = vector::borrow_mut<SupporterReward>(storage_sr, 0);
            suifund::do_merge(sr_mut, supporter_reward);
        };

        let treasury = suifund::borrow_mut_in_project<std::ascii::String, TreasuryCap<T>>(project_record, std::ascii::string(b"treasury"));
        coin::mint<T>(treasury, value, ctx)
    }

    public entry fun sr_to_coin_swap<T>(
        project_record: &mut ProjectRecord,
        supporter_reward: SupporterReward,
        ctx: &mut TxContext
    ) {
        let coin = sr_to_coin<T>(project_record, supporter_reward, ctx);
        transfer::public_transfer(coin, ctx.sender());
    }

    public fun coin_to_sr<T>(
        project_record: &mut ProjectRecord,
        sr_coin: Coin<T>,
        ctx: &mut TxContext
    ): SupporterReward {
        assert!(suifund::exists_in_project<std::ascii::String>(project_record, std::ascii::string(b"coin_type")), ENotInit);
        let treasury = suifund::borrow_mut_in_project<std::ascii::String, TreasuryCap<T>>(project_record, std::ascii::string(b"treasury"));
        let value = coin::burn<T>(treasury, sr_coin);
        assert!(value > 0, EZeroCoin);

        let storage_sr = suifund::borrow_mut_in_project<std::ascii::String, vector<SupporterReward>>(project_record, std::ascii::string(b"storage_sr"));
        let sr_b = vector::borrow<SupporterReward>(storage_sr, 0);
        let sr_tsv = suifund::sr_amount(sr_b);

        if (sr_tsv == value) {
            vector::pop_back<SupporterReward>(storage_sr)
        } else {
            let sr_bm = vector::borrow_mut<SupporterReward>(storage_sr, 0);
            suifund::do_split(sr_bm, value, ctx)
        }
    }

    public entry fun coin_to_sr_swap<T>(
        project_record: &mut ProjectRecord,
        sr_coin: Coin<T>,
        ctx: &mut TxContext
    ) {
        let sr = coin_to_sr<T>(project_record, sr_coin, ctx);
        transfer::public_transfer(sr, ctx.sender());
    }
}