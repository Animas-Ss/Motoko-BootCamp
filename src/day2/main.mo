import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";

import Type "Types";

actor class Homework() {
  type Homework = Type.Homework;

  let homeworkDiary = Buffer.Buffer<Homework>(0);

  // Add a new homework task
  public shared func addHomework(homework : Homework) : async Nat {
    homeworkDiary.add(homework);
    return homeworkDiary.size();
  };

  // Get a specific homework task by id
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    let newid: Nat = id - 1;
    let todo = homeworkDiary.getOpt(newid);
    if (todo != null) {
      return #ok(homeworkDiary.get(newid));
    } else {
      return #err("tarea no existente");
    };
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    let newid: Nat = id - 1;
    let todo = homeworkDiary.getOpt(newid);
    if (todo != null) {
     let res = homeworkDiary.put(newid, homework);
      return #ok(res);
    } else {
      return #err("not implemented");
    };
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    let newid: Nat = id - 1;
    let todo = homeworkDiary.getOpt(newid);
    if (todo != null) {
      let res = homeworkDiary.get(newid);
      let newTodo : Homework = {
        title = res.title;
        description = res.description;
        dueDate = res.dueDate;
        completed = true;
      };
      let new = homeworkDiary.put(newid, newTodo);
      return #ok(new);
    } else {
      return #err("not implemented");
    };
  };

  // Delete a homework task by id
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    let newid: Nat = id - 1;
    let todo = homeworkDiary.getOpt(newid);
    if (todo != null) {
      let x = homeworkDiary.remove(newid);
      return #ok();
    } else {
      return #err("not implemented");
    };
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    let res = Buffer.toArray(homeworkDiary);
    return res;
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework] {
   let arrayRes = Buffer.Buffer<Homework>(0);
    for (element in homeworkDiary.vals()){
           if(not element.completed){
               arrayRes.add(element);
           }
    };
   let res = Buffer.toArray(arrayRes);
    return res;
  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
    let resultado = Buffer.Buffer<Homework>(0);
    for(element in homeworkDiary.vals()){
          if(element.title == searchTerm or element.description == searchTerm){
            resultado.add(element);
          }
    };
    let res = Buffer.toArray(resultado);
    return res;
  };
};