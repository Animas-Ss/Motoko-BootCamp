import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";

import Account "Account";

import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Array "mo:base/Array";

actor class MotoCoin() {
  public type Account = Account.Account;

  let ledger = TrieMap.TrieMap<Account.Account, Nat>(Account.accountsEqual, Account.accountsHash);

  // Returns the name of the token
  public query func name() : async Text {
    return "MotoCoin";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return "MOC";
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    var MOC_total  = 0;
    for (key in ledger.vals()) {
      MOC_total := MOC_total + key;
    };
    return MOC_total;
  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {
    switch(ledger.get(account)){
      case(null){
        return (0);
      };
      case(?saldo){
        return (saldo);
      };
    };
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(from : Account, to : Account, amount : Nat) : async Result.Result<(), Text> {
    switch (ledger.get(from)) {
      case (null) {
        return #err("from not exits");
      };
      case (?from_res) {
        switch (ledger.get(to)) {
          case (null) {
            return #err("to not exits");
          };
          case (?to_res) {
            if (from_res >= amount) {
              let saldo_from : Nat = from_res - amount;
              let saldo_to : Nat = to_res + amount;
              ignore ledger.replace(from, saldo_from);
              ignore ledger.replace(to, saldo_to);
            } else {
              return #err("no enough coins");
            };
          };
        };
      };
    };
    return #ok();
  };

let MOC_students : actor {getAllStudentsPrincipal: () -> async [Principal] } = actor("rww3b-zqaaa-aaaam-abioa-cai");
  // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {
    // de forma local
    //let allStudens = await BootcampLocalActor.BootcampLocalActor();
    let allStudens = await MOC_students.getAllStudentsPrincipal();
    if(allStudens.size() <= 0) return #err("no hay estudiantes");

    let saveAccount = func (student: Principal): Nat {
      let account = {
        owner = student;
        subaccount = null;
      };
      let value = ledger.get(account);
      ledger.put(account, Option.get(value, 0) + 100);
      return 0;
    };

    let as = Array.map(allStudens, saveAccount);

    return #ok(());
  };
};
