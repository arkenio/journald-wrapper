#!/usr/bin/env ruby
require "em-eventsource"
require "aws-sdk"
require "json"
require "net/http"
require "open-uri"

class CloudWatchDispatcher
  def initialize()
    @last_cursor_file = File.join(ENV["CURSOR_PATH"], "last_cursor")

    @cloudwatch = Aws::CloudWatchLogs::Client.new()

    instance_id = open("http://169.254.169.254/latest/meta-data/instance-id").read
    @log_group = "#{ENV["PREFIX"]}_#{instance_id}"

    # Initialize instance group logs
    ret = @cloudwatch.describe_log_groups({log_group_name_prefix: @log_group, limit: 1})
    @cloudwatch.create_log_group({log_group_name: @log_group}) unless ret.log_groups.length > 0
  end

  def log_entry(entry)
    log_stream = entry["_SYSTEMD_UNIT"].nil? ? "#{entry["SYSLOG_IDENTIFIER"]}" : entry["_SYSTEMD_UNIT"];
    seq_token = check_log_stream(log_stream);
    res = @cloudwatch.put_log_events({
      log_group_name: @log_group,
      log_stream_name: log_stream,
      log_events: [{
        timestamp: entry["__REALTIME_TIMESTAMP"].to_i / 1000,
        message: entry["MESSAGE"]
      }],
      sequence_token: seq_token
    })
    save_cursor(entry["__CURSOR"])
  end

  def check_log_stream(name)
    # check and create log stream if needed
    ret = @cloudwatch.describe_log_streams({log_group_name: @log_group,
      log_stream_name_prefix: "#{name}",
      limit: 1})

    return ret.log_streams[0][:upload_sequence_token] unless ret.log_streams.length == 0

    @cloudwatch.create_log_stream({log_group_name: @log_group, log_stream_name: "#{name}"})
    nil
  end

  def save_cursor(cursor)
    f = open(@last_cursor_file, "w")
    f.write(cursor)
    f.close
  end

  def last_cursor()
    begin
      open(@last_cursor_file).read
    rescue
      nil
    end
  end
end

cw = CloudWatchDispatcher.new
EM.run do
  source = EventMachine::EventSource.new('http://172.17.42.1:19531/entries?follow', nil, {"Range" => "entries=#{cw.last_cursor}"})
  source.message do |message|
    begin
      cw.log_entry(JSON.parse(message))
    rescue
    end
  end
  source.start
end
