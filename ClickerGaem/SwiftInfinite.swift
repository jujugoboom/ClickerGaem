//
//  SwiftInfinite.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/13/24.
//

import Foundation
import CoreData

let numExpMax = 308
let numExpMin = -324
let maxSignificantDigits = 17
let roundTolerance = 1e-10
let maxInt = Double(Int.max)
let expMax = Int.max

/// Instead of figuring out what 10^power is every time we need to, just do it for all the ones we could need once
struct PowersOf10 {
    static let indexOf0 = 323;
    static var powersOf10: [Double] = []
    
    init() {
        guard PowersOf10.powersOf10.isEmpty else {
            return
        }
        for i in numExpMin + 1...numExpMax {
            PowersOf10.powersOf10.append(Double("1e\(i)")!)
        }
    }
    
    static func getPower(power: Int) -> Double {
        let _ = PowersOf10()
        return PowersOf10.powersOf10[power + indexOf0]
    }
}

/// A conversion of break\_infinity.js to swift. I have no idea if the performance is good, but it seems to work fine when not listening for breakpoints
/// A very basic representation of float values with a Double mantissa and Integer exponent. There are minimal checks for overflows or other unwanted behavior, but generally holds up
class InfiniteDecimal: NSObject, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, Codable {
    var m: Double
    var e: Int
    
    static let powersOf10 = PowersOf10()
    static let nanDecimal = InfiniteDecimal(source: Double.nan)
    static let zeroDecimal = InfiniteDecimal(source: 0)
    static let infiniteDecimal = InfiniteDecimal(source: Double.infinity)
    static let standardAbbreviations = ["K", "M", "B", "T", "Qa", "Qt", "Sx", "Sp", "Oc", "No"]
    static let ln10 = Darwin.log(10.0)
    
    /// Again, my first swift project. Default init that generally should not be used
    override init() {
        m = 0
        e = 0
        super.init()
    }
    
    /// Initializes from given Double
    /// exponent is log\_10 source value, rounded down
    /// mantissa is source / 10^exponent
    convenience init(source: Double) {
        self.init()
        guard source.isFinite else {
            m = source
            e = 0
            return
        }
        
        guard !source.isZero else {
            m = 0
            e = 0
            return
        }
        
        e = Int(Darwin.floor(Darwin.log10(Swift.abs(source))))
        m = e == numExpMin ? source * 10 / 1e-323 : source / PowersOf10.getPower(power: e)
        normalize()
    }
    
    /// Initialize from string. Supports any string representation that can be used with Double
    /// Convert to double and init from there
    convenience init(source: String) {
        self.init(source: Double(source) ?? Double.nan)
    }
    
    /// Copy constructor
    init(copyFrom: InfiniteDecimal) {
        m = copyFrom.m
        e = copyFrom.e
    }
    
    /// Init from given mantissa and exponent. Can choose to normalize
    convenience init(mantissa: Double, exponent: Double, shouldNormalize: Bool = false) {
        guard exponent.isFinite && exponent < maxInt else {
            self.init(copyFrom: InfiniteDecimal.infiniteDecimal)
            return
        }
        self.init(mantissa: mantissa, exponent: Int(exponent), shouldNormalize: shouldNormalize)
    }
    
    /// Init from given mantissa and component. Can choose to normalize
    /// I typed that out twice
    convenience init(mantissa: Double, exponent: Int, shouldNormalize: Bool = false) {
        guard !mantissa.isNaN else {
            self.init(copyFrom: InfiniteDecimal.nanDecimal)
            return
        }
        guard mantissa.isFinite else {
            self.init(copyFrom: InfiniteDecimal.infiniteDecimal)
            return
        }
        self.init()
        m = mantissa
        e = exponent
        if shouldNormalize {
            normalize()
        }
    }
    
    required convenience init(integerLiteral value: Int) {
        self.init(source: Double(value))
    }
    
    required convenience init(floatLiteral value: Float) {
        self.init(source: Double(value))
    }
    
    /// Normalizes the number. This _should_ bring the mantissa into [1, 10]
    /// does a log\_10 of mantissa and adds it to the exponent
    /// divides mantissa by 10^exponent
    func normalize() {
        guard m < 1 || m >= 10 else {
            return
        }
        
        if m.isZero {
            m = 0
            e = 0
            return
        }
        
        let tempExponent = Int(Darwin.floor(Darwin.log10(Swift.abs(m))))
        
        m = tempExponent == numExpMin ? m * 10 / 1e-323 : m / PowersOf10.getPower(power: tempExponent)
        e += tempExponent
    }
    
    /// Should move this to a property, dont feel like refactoring
    func isFinite() -> Bool {
        return m.isFinite
    }
    
    /// Converts to double, but will obviously overflow for numbers larger than double can handle, returning infinity
    func toDouble() -> Double {
        if !isFinite() {
            return m
        }
        
        if e > numExpMax {
            return m > 0 ? Double.infinity : -Double.infinity
        }
        
        if e < numExpMin {
            return 0
        }
        
        if e == numExpMin {
            return m > 0 ? 5e-324 : -5e-324
        }
        
        let result = m * PowersOf10.getPower(power: e)
        
        if !result.isFinite || e < 0 {
            return result
        }
        
        let resultRounded = Darwin.round(result)
        if Swift.abs(resultRounded - result) < roundTolerance {
            return resultRounded
        }
        return result
    }
    
    /// Convert to int. does not handle infinity, you do
    func toInt() -> Int {
        let double = self.toDouble()
        guard double > Double(Int.min) && double < Double(Int.max) else {
            return 0
        }
        return Int(double)
    }
    
    func abs() -> InfiniteDecimal {
        return InfiniteDecimal(mantissa: Swift.abs(m), exponent: e)
    }
    
    func neg() -> InfiniteDecimal {
        return InfiniteDecimal(mantissa: -m, exponent: e)
    }
    
    func negate() -> InfiniteDecimal {
        return neg()
    }
    
    func sign() -> FloatingPointSign {
        return m.sign
    }
    
    func round() -> InfiniteDecimal {
        if e < -1 {
            return InfiniteDecimal.zeroDecimal
        }
        
        if e < maxSignificantDigits {
            return InfiniteDecimal(source: Darwin.round(toDouble()))
        }
        
        return self
    }
    
    func add(value: InfiniteDecimal) -> InfiniteDecimal {
        guard isFinite() else {
            return InfiniteDecimal(copyFrom: self)
        }
        guard value.isFinite() else {
            return InfiniteDecimal(copyFrom: value)
        }
        guard m != 0 else {
            return InfiniteDecimal(copyFrom: value)
        }
        guard value.m != 0 else {
            return InfiniteDecimal(copyFrom: self)
        }
        var bigger: InfiniteDecimal
        var smaller: InfiniteDecimal
        
        if e > value.e {
            bigger = self
            smaller = value
        } else {
            bigger = value
            smaller = self
        }
        
        if bigger.e - smaller.e > maxSignificantDigits {
            // Don't bother adding if they are far enough apart
            return InfiniteDecimal(copyFrom: bigger)
        }
        
        let mantissa = Darwin.round(1e14 * bigger.m + 1e14 * smaller.m * PowersOf10.getPower(power: smaller.e - bigger.e));
        return InfiniteDecimal(mantissa: mantissa, exponent: bigger.e - 14, shouldNormalize: true)
    }
    
    func sub(value: InfiniteDecimal) -> InfiniteDecimal {
        return add(value: value.neg())
    }
    
    func mul(value: InfiniteDecimal) -> InfiniteDecimal {
        return InfiniteDecimal(mantissa: m * value.m, exponent: e + value.e, shouldNormalize: true)
    }
    
    func div(value: InfiniteDecimal) -> InfiniteDecimal {
        return mul(value: value.recip())
    }
    
    func recip() -> InfiniteDecimal {
        return InfiniteDecimal(mantissa: 1/m, exponent: -e, shouldNormalize: true)
    }
    
    func log10() -> Double {
        return Double(e) + Darwin.log10(m)
    }
    
    func absLog10() -> Double {
        return Double(e) + Darwin.log10(Swift.abs(m))
    }
    
    func log(base: Double) -> Double{
        return (InfiniteDecimal.ln10 / Darwin.log(base)) * self.log10()
    }
    
    func pow10(value: Double) -> InfiniteDecimal {
        if Darwin.floor(value) == value {
            return InfiniteDecimal(mantissa: 1, exponent: value)
        }
        return InfiniteDecimal(mantissa: Darwin.pow(10, value.truncatingRemainder(dividingBy: 1)), exponent: value, shouldNormalize: true)
    }
    
    func pow(value: InfiniteDecimal) -> InfiniteDecimal {
        guard !m.isZero else {
            return self
        }
        
        let numberValue = value.toDouble()
        let temp = Double(e) * numberValue;
        if Darwin.floor(temp) == temp {
            let newM = Darwin.pow(m, numberValue)
            if newM.isFinite && !newM.isZero {
                return InfiniteDecimal(mantissa: newM, exponent: temp, shouldNormalize: true)
            }
        }
        
        let newE = Darwin.floor(temp)
        let residue = temp - newE
        
        let newM = Darwin.pow(10, numberValue * Darwin.log10(m) + residue)
        if newM.isFinite && !newM.isZero {
            return InfiniteDecimal(mantissa: newM, exponent: newE, shouldNormalize: true)
        }
        let result = pow10(value: numberValue * absLog10())
        if sign() == .minus {
            if Swift.abs(numberValue.truncatingRemainder(dividingBy: 2)) == 1 {
                return result.neg()
            } else if Swift.abs(numberValue.truncatingRemainder(dividingBy: 2)) == 0 {
                return result
            }
            return InfiniteDecimal.nanDecimal
        }
        return result
    }
    
    func gt(other: InfiniteDecimal) -> Bool {
        if m.isZero {
            return other.m < 0
        }
        if other.m.isZero {
            return m > 0
        }
        
        if e == other.e {
            return m > other.m
        }
        if m > 0 {
            return other.m < 0 || e > other.e
        }
        return m < 0 && e < other.e
    }
    
    func lt(other: InfiniteDecimal) -> Bool {
        if m.isZero {
            return other.m > 0
        }
        if other.m.isZero {
            return m <= 0
        }
        if e == other.e {
            return m < other.m
        }
        
        if m > 0 {
            return other.m > 0 && e < other.e
        }
        return other.m > 0 || e > other.e
    }
    
    func gte(other: InfiniteDecimal) -> Bool {
        return !lt(other: other)
    }
    
    func lte(other: InfiniteDecimal) -> Bool {
        return !gt(other: other)
    }
    
    func max(other: InfiniteDecimal) -> InfiniteDecimal {
        return lt(other: other) ? other : self
    }
    
    func min(other: InfiniteDecimal) -> InfiniteDecimal {
        return lt(other: other) ? self : other
    }
    
    func eq(other: InfiniteDecimal) -> Bool {
        return self.m == other.m && self.e == other.e
    }
    
    func floor() -> InfiniteDecimal {
        guard isFinite() else {
            return self
        }
        
        guard e >= -1 else {
            return m.sign == .plus ? 0 : -1
        }
        
        guard e >= maxSignificantDigits else {
            return InfiniteDecimal(source: Darwin.floor(toDouble()))
        }
        
        return self
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.m, forKey: "m")
        coder.encode(self.e, forKey: "e")
    }
    
    required init?(coder: NSCoder) {
        self.m = coder.decodeDouble(forKey: "m")
        self.e = coder.decodeInteger(forKey: "e")
    }
    
    static func == (lhs: InfiniteDecimal, rhs: InfiniteDecimal) -> Bool {
        lhs.eq(other: rhs)
    }
}

extension InfiniteDecimal: NSSecureCoding {
    static var supportsSecureCoding: Bool {
        true
    }
}

extension InfiniteDecimal {
    /// This is an awful recreation of the mixed-scientific format in AD. Works \shrug
    override var description: String {
        toString()
    }
    
    func toString() -> String {
        guard isFinite() else {
            return m.formatted()
        }
        guard e > -expMax && !m.isZero else {
            return "0"
        }
        guard e >= 33 || e <= -7 else {
            let exponent = Swift.max(Darwin.floor(self.log(base: 1000)), 0)
            let mantissa = self.div(value: InfiniteDecimal(source: Darwin.pow(1000, exponent))).toDouble()
            guard exponent > 0 else {
                return mantissa.formatted(.number.precision(.fractionLength(2)))
            }
            return "\(mantissa.formatted(.number.precision(.fractionLength(2))))\(InfiniteDecimal.standardAbbreviations[Int(exponent - 1)])"
        }
        return "\(m.formatted(.number.precision(.fractionLength(2))))e\(e)"
    }
}

@objc(InfiniteDecimalTransformer)
public final class InfiniteDecimalTransformer: ValueTransformer {
    override public class func transformedValueClass() -> AnyClass {
        InfiniteDecimal.self
    }
    
    override public class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override public func transformedValue(_ value: Any?) -> Any? {
        guard let decimal = value as? InfiniteDecimal else {
            return nil
        }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: decimal, requiringSecureCoding: true)
            return data
        } catch {
            assertionFailure("Failed to transform `InfiniteDecimal` to `Data`")
            return nil
        }
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else {
            return nil
        }
        
        do {
            let decimal = try NSKeyedUnarchiver.unarchivedObject(ofClass: InfiniteDecimal.self, from: data as Data)
            return decimal
        } catch {
            assertionFailure("Failed to transform `Data` to `InfiniteDecimal`")
            return nil
        }
    }
}

extension InfiniteDecimalTransformer {
    /// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: InfiniteDecimalTransformer.self))

    /// Registers the value transformer with `ValueTransformer`.
    public static func register() {
        let transformer = InfiniteDecimalTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
