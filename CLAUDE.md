# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This project models the London Underground network as a Neo4j graph database. It reads station/line data from YAML and populates a Neo4j instance with station nodes connected by line relationships.

## Prerequisites

- **JRuby** — the `neo4j` gem v2.x wraps the Neo4j embedded Java library and requires JRuby, not MRI Ruby.
- **Bundler** — install dependencies via `jruby -S bundle install`. Ensure JRuby's bin directory takes priority over the system Ruby in `PATH`, otherwise the system `bundle` will be picked up instead.

## Running

Ensure JRuby's bin directory is first on `PATH`, then:

```bash
PATH="$(jruby -e 'puts RbConfig::CONFIG["bindir"]'):$PATH" jruby -S bundle exec ruby graph.rb
```

## Architecture

Two files make up the entire project:

- **`graph.rb`** — Reads `underground.yaml`, creates `Neo4j::Node` objects for each station (deduplicating by name using a `station_node_ids` hash), then connects consecutive stations with bidirectional relationships named after the line (e.g., `:Northern`, `:"Hammersmith & City"`).
- **`underground.yaml`** — Defines the network as a list of records, each with `:line_name` and a sequential `:stations` array. Branching lines appear as multiple records sharing the same `:line_name` (e.g., Northern line has 4 entries for its branches).

### Key design decisions

- Stations shared between lines (e.g., King's Cross St. Pancras) are represented as a single node; the `station_node_ids` hash maps station name → Neo4j node ID to enable reuse.
- Relationships are added in both `outgoing` and `incoming` directions on `node_one`, making traversal symmetric without needing separate relationship direction logic at query time.
- All station creation and linking for a given line segment runs inside a single `Neo4j::Transaction`.
