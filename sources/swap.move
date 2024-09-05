module suifund::swap {
    use std::{ascii::String, type_name};
    use sui::coin::{Coin, TreasuryCap, CoinMetadata};
    use suifund::suifund::{Self, ProjectRecord, ProjectAdminCap, SupporterReward, AdminCap};

    const COIN_TYPE: vector<u8> = b"coin_type";
    const TREASURY: vector<u8> = b"treasury";
    const STORAGE: vector<u8> = b"storage_sr";

    const EAlreadyInit: u64 = 100;
    const EExpectZeroDecimals: u64 = 101;
    const EInvalidTreasuryCap: u64 = 102;
    const ENotInit: u64 = 103;
    const ENotSameProject: u64 = 104;
    const EZeroCoin: u64 = 105;
    const ENotBegin: u64 = 106;

    public fun init_swap_by_project_admin<T>(
        project_admin_cap: &ProjectAdminCap,
        project_record: &mut ProjectRecord,
        treasury_cap: TreasuryCap<T>,
        metadata: &CoinMetadata<T>,
    ) {
        suifund::check_project_cap(project_record, project_admin_cap);
        init_swap<T>(project_record, treasury_cap, metadata);
    }

    public fun init_swap_by_admin<T>(
        _: &AdminCap,
        project_record: &mut ProjectRecord,
        treasury_cap: TreasuryCap<T>,
        metadata: &CoinMetadata<T>,
    ) {
        init_swap<T>(project_record, treasury_cap, metadata);
    }

    fun init_swap<T>(
        project_record: &mut ProjectRecord,
        treasury_cap: TreasuryCap<T>,
        metadata: &CoinMetadata<T>,
    ) {
        assert!(!project_record.has_key(COIN_TYPE), EAlreadyInit);
        assert!(project_record.project_begin_status(), ENotBegin);
        assert!(treasury_cap.total_supply() == 0, EInvalidTreasuryCap);
        assert!(metadata.get_decimals() == 0, EExpectZeroDecimals);

        let coin_type = type_name::get_with_original_ids<T>().into_string();

        project_record.add_df_in_project(COIN_TYPE.to_ascii_string(), coin_type);
        project_record.add_df_in_project(TREASURY.to_ascii_string(), treasury_cap);
        project_record.add_df_in_project(STORAGE.to_ascii_string(), vector<SupporterReward>[]);
    }

    public fun sr_to_coin<T>(
        project_record: &mut ProjectRecord,
        supporter_reward: SupporterReward,
        ctx: &mut TxContext,
    ): Coin<T> {
        assert!(project_record.has_key(COIN_TYPE), ENotInit);
        assert!(project_record.project_name() == supporter_reward.sr_name(), ENotSameProject);

        let value = supporter_reward.sr_amount();
        let storage_sr = project_record.storage_mut();
        if (storage_sr.is_empty()) {
            storage_sr.push_back(supporter_reward);
        } else {
            storage_sr[0].do_merge(supporter_reward);
        };

        project_record.treasury_mut().mint(value, ctx)
    }

    #[allow(lint(self_transfer))]
    // TODO: create a composable version which returns `(): Coin<T>`
    public fun sr_to_coin_swap<T>(
        project_record: &mut ProjectRecord,
        supporter_reward: SupporterReward,
        ctx: &mut TxContext,
    ) {
        let coin = sr_to_coin<T>(project_record, supporter_reward, ctx);
        transfer::public_transfer(coin, ctx.sender());
    }

    public fun coin_to_sr<T>(
        project_record: &mut ProjectRecord,
        sr_coin: Coin<T>,
        ctx: &mut TxContext,
    ): SupporterReward {
        assert!(project_record.has_key(COIN_TYPE), ENotInit);
        let value = project_record.treasury_mut().burn(sr_coin);
        assert!(value > 0, EZeroCoin);

        let storage_sr = project_record.storage_mut();
        let sr_tsv = storage_sr[0].sr_amount();

        if (sr_tsv == value) {
            storage_sr.pop_back()
        } else {
            storage_sr[0].do_split(value, ctx)
        }
    }

    #[allow(lint(self_transfer))]
    // TODO: create a composable version which returns `(): Coin<T>`
    public fun coin_to_sr_swap<T>(
        project_record: &mut ProjectRecord,
        sr_coin: Coin<T>,
        ctx: &mut TxContext,
    ) {
        let sr = coin_to_sr<T>(project_record, sr_coin, ctx);
        transfer::public_transfer(sr, ctx.sender());
    }

    // for update CoinMetadata purposes
    public fun borrow_treasury_cap_by_project_admin<T>(
        project_record: &mut ProjectRecord,
        project_admin_cap: &ProjectAdminCap,
    ): &TreasuryCap<T> {
        project_record.check_project_cap(project_admin_cap);
        assert!(project_record.has_key(COIN_TYPE), ENotInit);
        project_record.treasury()
    }

    public fun borrow_treasury_cap_by_admin<T>(
        _: &AdminCap,
        project_record: &mut ProjectRecord,
    ): &TreasuryCap<T> {
        assert!(project_record.has_key(COIN_TYPE), ENotInit);
        project_record.treasury()
    }

    // ======== Read Functions =========

    public fun get_coin_type(project_record: &ProjectRecord): &String {
        &project_record[COIN_TYPE.to_ascii_string()]
    }

    public fun get_total_supply<T>(project_record: &ProjectRecord): u64 {
        let treasury: &TreasuryCap<T> = &project_record[TREASURY.to_ascii_string()];
        treasury.total_supply()
    }

    // ======= Internal Accessors for Readability ========

    use fun treasury_mut as ProjectRecord.treasury_mut;
    use fun storage_mut as ProjectRecord.storage_mut;
    use fun treasury as ProjectRecord.treasury;
    use fun has_key as ProjectRecord.has_key;

    fun has_key(record: &ProjectRecord, key: vector<u8>): bool {
        record.exists_in_project(key.to_ascii_string())
    }

    fun treasury<T>(record: &ProjectRecord): &TreasuryCap<T> {
        &record[TREASURY.to_ascii_string()]
    }

    fun storage_mut(record: &mut ProjectRecord): &mut vector<SupporterReward> {
        &mut record[STORAGE.to_ascii_string()]
    }

    fun treasury_mut<T>(record: &mut ProjectRecord): &mut TreasuryCap<T> {
        &mut record[TREASURY.to_ascii_string()]
    }
}
