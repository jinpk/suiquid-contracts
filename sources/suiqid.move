// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// This example demonstrates a basic use of a shared object.
/// Rules:
/// - anyone can create and share a counter
/// - everyone can increment a counter by 1
/// - the owner of the counter can reset it to any value
module basics::suiquid {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use std::string;
    use std::vector;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance, Supply};

    struct Ad has store, drop {
        id: u64,
        title: string::String,
        url: string::String,
        deposit: u64,
        state: string::String
    }

    struct Suiquid has key {
        id: UID,
        owner: address,
        inventory: vector<Ad>
    }

    public fun owner(suiquid: &Suiquid): address {
        suiquid.owner
    }

    // public fun value(suiquid: &Suiquid): vector<Ad> {
    //     suiquid.inventory
    // }

    public entry fun create(ctx: &mut TxContext) {
        transfer::share_object(Suiquid {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            inventory: vector::empty<Ad>()
        })
    }

    public entry fun add_ad(suiquid: &mut Suiquid, title: string::String, url: string::String, state: string::String, deposit: u64, ctx: &mut TxContext,) {
        let l = vector::length(&mut suiquid.inventory);
        let item = Ad {
            id: l,
            title: title,
            url: url,
            deposit: deposit,
            state: state
        };
        //TODO transfer Coin to Module
        vector::push_back(&mut suiquid.inventory, item);
    }

    public entry fun prize(suiquid: &mut Suiquid, address: address, id: u64, ctx: &mut TxContext) {
        assert!(suiquid.owner == tx_context::sender(ctx), 0);
        //TODO transfer Module to Coin
        //Update Ad deposit, state
        let ads = &mut suiquid.inventory;
        let i = index_of_ad(ads, id);
        let ad = vector::borrow_mut(ads, i);
        ad.deposit = 0;
        //ad.deposit
        // let balance = Balance { value: 0 };
        // let coin = coin::from_balance(Balance { value: ad.deposit }, ctx);
        // transfer::public_transfer(coin, address);
        // vector::remove(&mut suiquid.inventory, i);
    }

    fun index_of_ad(ads: &vector<Ad>, id: u64): u64 {
        let i = 0;
        let l = vector::length(ads);
        while (i < l) {
            let ad = vector::borrow(ads, i);
            if (ad.id == id) {
                return i
            };
            i = i + 1;
       };
       return l
    }
}