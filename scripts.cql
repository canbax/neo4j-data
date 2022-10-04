// constraints from Neo4j Sandbox
CREATE INDEX FOR (node:Movie) ON (node.tagline);
CREATE INDEX FOR (node:Movie) ON (node.released);
CREATE INDEX FOR (node:Person) ON (node.name);
CREATE INDEX FOR (node:Movie) ON (node.imdbRating);
CREATE INDEX FOR (node:User) ON (node.name);
CREATE INDEX FOR (node:Movie) ON (node.title);
CREATE INDEX FOR (node:Movie) ON (node.year);
CREATE INDEX FOR (node:Movie) ON (node.imdbId);
CREATE CONSTRAINT ON (node:Movie) ASSERT (node.movieId) IS UNIQUE;
CREATE CONSTRAINT ON (node:Movie) ASSERT (node.tmdbId) IS UNIQUE;
CREATE CONSTRAINT ON (node:Genre) ASSERT (node.name) IS UNIQUE;
CREATE CONSTRAINT ON (node:Person) ASSERT (node.tmdbId) IS UNIQUE;
CREATE CONSTRAINT ON (node:User) ASSERT (node.userId) IS UNIQUE;

// extra indexes for ID
CREATE CONSTRAINT FOR (node:Movie) REQUIRE (node.id) IS UNIQUE;
CREATE CONSTRAINT FOR (node:Genre) REQUIRE (node.id) IS UNIQUE;
CREATE CONSTRAINT FOR (node:Person) REQUIRE (node.id) IS UNIQUE;
CREATE CONSTRAINT FOR (node:User) REQUIRE (node.id) IS UNIQUE;

// export all nodes to a JSON
MATCH (n)
WITH collect(n) AS all_nodes
CALL apoc.export.json.data(all_nodes, [], "all-nodes.json", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data

// export all edges to a JSON
MATCH ()-[e]->()
WITH collect(e) AS all_edges
CALL apoc.export.json.data([], all_edges, "all-edges.json", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data

// export all edges to a CSV
MATCH ()-[e]->()
WITH collect(e) AS all_edges
CALL apoc.export.csv.data([], all_edges, "all-edges.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data

// takes like 30 seconds
// create nodes
CALL apoc.load.json("file:///all-nodes.json")
YIELD value
MERGE (n {id: value.id})
SET n += value.properties
WITH n, value
CALL apoc.create.addLabels([n], value.labels) YIELD node return node limit 5

// create edges using JSON will take 1 hour!
CALL apoc.load.json("file:///all-edges.json")
YIELD value
MATCH (n1{id: value.start.id})
MATCH (n2{id: value.end.id})
CALL apoc.create.relationship(n1, value.label, value.properties, n2)
YIELD rel
RETURN null;

// create edges using CSV (take 1 HOUR!)
LOAD CSV WITH HEADERS FROM 'file:///all-edges.csv' AS r
match (n1{id: r._start})
match (n2{id: r._end})
CALL apoc.create.relationship(n1, r._type, {rating: r.rating, role: r.role, timestamp: r.timestamp }, n2)
YIELD rel
return rel 