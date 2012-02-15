require '/assets/application.js'

describe 'a simple test', ->
  it 'ensures 2 plus 2 is 4', ->
    expect(TestObject.first + TestObject.second).toEqual(TestObject.sum)
