require 'yaml'
require 'neo4j'

yaml = YAML.load_file "underground.yaml"
station_node_ids = Hash.new

def connect_stations(node_one, node_two, line_name)
  unless (node_one == nil)
    node_one.outgoing(line_name.to_sym) << node_two
    node_one.incoming(line_name.to_sym) << node_two
  end
end

yaml.each do |record|
  last_node, this_node = nil
  line_name = record[:line_name]
  stations = record[:stations]
  link_from = record[:link_from]
  link_to = record[:link_to]

  Neo4j::Transaction.run do |txn|
    unless (link_from == nil)
      last_node = Neo4j::Node.load(station_node_ids[link_from])
    end
    stations.each do |station|
      this_node = Neo4j::Node.new :name => station
      station_node_ids[station] = this_node.getId
      p station_node_ids[station]

      connect_stations(last_node, this_node, line_name)

      last_node = this_node # Last step in the iteration
    end
    # txn.failure
  end
end