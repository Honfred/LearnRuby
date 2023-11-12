require 'bunny'
require 'json'

connection = Bunny.new('amqp://guest:guest@rabbitmq')
connection.start

channel = connection.create_channel
queue1 = channel.queue('vm_params')
queue2 = channel.queue('vm_cost')

exchange = channel.default_exchange

begin
  queue1.subscribe(block: true) do |_delivery_info, _metadata, payload|
  #StopVmService.call(payload)
  data = JSON.parse(payload)

  total_cost = vm_cost(data['cpu'], data['ram'], data['hdd'])

  exchange.publish(
    { cost: total_cost }.to_json,
    routing_key: queue2
  )
  end
  
rescue Interrupt => _
  connection.close
end

def vm_cost(cpu, ram, hdd)
  cpu = cpu * 5
  ram = ram * 5
  hdd = hdd * 10
  total_cost = cpu + ram + hdd
end