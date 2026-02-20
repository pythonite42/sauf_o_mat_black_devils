/*
Maximale Zeichenanzahlen: 

Name FROM Team__c -> 20 //wäre ideal damit es beim Diagramm ganz angezeigt wird
Name FROM Team__c -> 30 //darf nicht länger sein weil es sonst an wichtigen Stellen wirklich blöd aussieht

Überschreitung ergibt keinen Fehler weil text abgeschnitten wird falls er zu lang ist
*/

class TestBackendData {
  Future<List<Map>> getPageDiagram() async {
    return List.filled(3, {
      "group": List.filled(20, "w").join(), //irrelevant weil ellipsis
      "longdrink": 99999,
      "beer": 99999,
      "shot": 99999,
      "luz": 99999,
      "status": "aufgestiegen",
    });
  }
}
