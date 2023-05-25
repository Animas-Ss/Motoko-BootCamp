import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Int "mo:base/Int";

actor class StudentWall() {
  type Message = Type.Message;
  type Content = Type.Content;
  type Survey = Type.Survey;
  type Answer = Type.Answer;

  stable var messageId : Nat = 1; // contiene la cantidad de mensajes publicados

  var wall = HashMap.HashMap<Nat, Message>(1, Nat.equal, Hash.hash);

  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
    let id : Nat = messageId;
    messageId := messageId + 1;
    let write : Message = {
      content = c;
      vote = 0;
      creator = caller;
    };
    wall.put(id, write);
    return id;
  };

  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    switch (wall.get(messageId)) {
      case (null) {
        return #err("Message not found, Mensaje no existe");
      };
      case (?res) {
        return #ok(res);
      };
    };
  };

  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    switch (wall.get(messageId)) {
      case (null) {
        return #err("The publication not found");
      };
      case (?res) {
        if (caller == res.creator) {
          let update : Message = {
            content = c;
            vote = res.vote;
            creator = res.creator;
          };
          ignore wall.replace(messageId, update);
          return #ok();
        } else {
          return #err("no puede modificar esta publicaion, you not modify this post");
        };
      };
    };
  };

  // Delete a specific message by ID
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    switch (wall.get(messageId)) {
      case (null) {
        return #err("Mensaje no existe");
      };
      case (?res) {
        wall.delete(messageId);
        return #ok();
      };
    };
  };

  // Voting
  public func upVote(messageId : Nat) : async Result.Result<(), Text> {
    switch (wall.get(messageId)) {
      case (null) {
        return #err("Mensaje no existe, Message not found");
      };
      case (?res) {
        let newVote : Message = {
          content = res.content;
          vote = res.vote + 1;
          creator = res.creator;
        };
        ignore wall.replace(messageId, newVote);
        return #ok();
      };
    };
  };

  public func downVote(messageId : Nat) : async Result.Result<(), Text> {
    switch (wall.get(messageId)) {
      case (null) {
        return #err("Message not found");
      };
      case (?res) {
        let newVote : Message = {
          content = res.content;
          vote = res.vote - 1;
          creator = res.creator;
        };
        ignore wall.replace(messageId, newVote);
        return #ok();
      };
    };
  };

  // Get all messages
  public func getAllMessages() : async [Message] {
    let msg = Buffer.Buffer<Message>(0);
    for (message in wall.vals()) {
      msg.add(message);
    };
    let res = Buffer.toArray<Message>(msg);
    return res;
  };

  // Get all messages ordered by votes
  public func getAllMessagesRanked() : async [Message] {
    let vote_msg = Buffer.Buffer<Message>(0);
    for (message in wall.vals()) {
      vote_msg.add(message);
    };
    vote_msg.sort(
      func order(x : Message, y : Message) : { #less; #equal; #greater } {
        if (x.vote > y.vote) {
          return #less;
        } else if (x.vote == y.vote) {
          return #equal;
        } else {
          return #greater;
        };
      }
    );
    let v = Buffer.toArray(vote_msg);
    Debug.print(debug_show (v));
    return v;
  };
};
