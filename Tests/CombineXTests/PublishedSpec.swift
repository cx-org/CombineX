import CXShim
import CXTestUtility
import Nimble
import Quick

class PublishedSpec: QuickSpec {
    
    #if swift(>=5.1)
    
    override func spec() {
        
        // MARK: - Publish
        describe("Publish") {
            
            // MARK: 1.1 should publish value's change
            it("Publish") {
                let obj = TestObject()
                let sub = obj.$value.subscribeTracingSubscriber(initialDemand: .unlimited)

                expect(sub.eventsWithoutSubscription) == [.value(0)]
                
                obj.value = 1
                obj.value = 2
                
                expect(sub.eventsWithoutSubscription) == [.value(0), .value(1), .value(2)]
            }
            
            // needs macOS 11 SDK (Xcode 12.2), check swift toolchain varion instead.
            #if compiler(>=5.3.1)
            
            it("test assign(to:) on Published.Publisher") {
                #if USE_COMBINE
                guard #available(macOS 11, iOS 14.0, tvOS 14.0, watchOS 7.0, *) else {
                    return
                }
                #endif
                
                weak var weakObj: TestObject?
                
                do {
                    let pub = TracingSubject<Int, Never>()
                    let obj = TestObject()
                    weakObj = obj
                    pub.assign(to: &obj.$value)
                    
                    expect(obj.value) == 0
                    expect(pub.subscription.demandRecords) == [.unlimited]
                    pub.send(1)
                    expect(obj.value) == 1
                    expect(pub.subscription.demandRecords) == [.unlimited, .none]
                }
                
                expect(weakObj).to(beNil())
            }
            
            it("projectedValue:setter doesn't have observable effect") {
                #if USE_COMBINE
                guard #available(macOS 11, iOS 14.0, tvOS 14.0, watchOS 7.0, *) else {
                    return
                }
                #endif
                
                let obj1 = TestObject(value: 1)
                let obj2 = TestObject(value: 2)
                
                expect(obj1.value) == 1
                expect(obj2.value) == 2
                
                let sub1 = obj1.$value.subscribeTracingSubscriber(initialDemand: .unlimited)
                let sub2 = obj2.$value.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(sub1.eventsWithoutSubscription) == [.value(1)]
                expect(sub2.eventsWithoutSubscription) == [.value(2)]
                
                obj1.$value = obj2.$value
                
                let newSub1 = obj1.$value.subscribeTracingSubscriber(initialDemand: .unlimited)
                let newSub2 = obj2.$value.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(newSub1.eventsWithoutSubscription) == [.value(1)]
                expect(newSub2.eventsWithoutSubscription) == [.value(2)]
                
                obj1.value = 3
                obj2.value = 4
                
                expect(sub1.eventsWithoutSubscription) == [.value(1), .value(3)]
                expect(sub2.eventsWithoutSubscription) == [.value(2), .value(4)]
                expect(newSub1.eventsWithoutSubscription) == [.value(1), .value(3)]
                expect(newSub2.eventsWithoutSubscription) == [.value(2), .value(4)]
            }
            
            #endif // compiler(>=5.3.1)
        }
        
        // MARK: - Demand
        describe("Demand") {
            
            // MARK: 2.1 should send as many values as demand
            it("should send as many values as demand") {
                let obj = TestObject()
                let sub = obj.$value.subscribeTracingSubscriber(initialDemand: .max(10)) { v in
                    return [0, 10].contains(v) ? .max(1) : .max(0)
                }

                100.times {
                    obj.value = $0
                }
                
                expect(sub.eventsWithoutSubscription.count) == 13
            }
        }
        
        // MARK: - Simultaneous accesses
        
        // https://github.com/cx-org/CombineX/issues/10
        describe("Simultaneous accesses") {
            
            it("should not simultaneous accesses") {
                class SomeDependency {
                    @Published var value = 0
                }

                class NestedObject {
                    let dependency: SomeDependency
                    var subscriptions = Set<AnyCancellable>()

                    init(dependency: SomeDependency) {
                        self.dependency = dependency

                        dependency.$value
                            .sink { value in
                                print("Nested:", value)
                            }
                            .store(in: &subscriptions)

                    }
                }

                class SuperObject {
                    let dependency: SomeDependency
                    var nestedObject: NestedObject?
                    var subscriptions = Set<AnyCancellable>()

                    init(dependency: SomeDependency) {
                        self.dependency = dependency

                        dependency.$value
                            .sink { [unowned self] value in
                                print("Super:", value)
                                if value == 1 {
                                    self.nestedObject = NestedObject(dependency: dependency)
                                }
                            }
                            .store(in: &subscriptions)
                    }
                }

                let dependency = SomeDependency()
                let _ = SuperObject(dependency: dependency)
                dependency.value = 1
            }
        }
    }
    
    class TestObject {
        
        @Published var value: Int
        
        init(value: Int = 0) {
            _value = Published(wrappedValue: value)
        }
    }
    
    #endif
}
