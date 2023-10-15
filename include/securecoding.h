// Copyright (c) 2023 LG Electronics, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

#ifndef SECURECODING_H
#define SECURECODING_H

#define checkIntMax(val) checkIntUpper(static_cast<int64_t>(val))
#define checkIntMin(val) checkIntLower(static_cast<int64_t>(val))

static int32_t uint2int(uint32_t val)
{
    if (val > INT_MAX)
    {
        qWarning() << "This conversion from uint to int may result in data lost, because the value exceeds INT_MAX. Before: " << val << ", After: " << INT_MAX;
        return INT_MAX;
    }

    return static_cast<int32_t>(val);
}

static uint32_t int2uint(int32_t val)
{
    if (val < 0)
    {
        qWarning() << "This conversion from int to uint may result in data lost, because the value is less than 0. Before: " << val << ", After: " << 0;
        return 0;
    }
    return static_cast<uint32_t>(val);
}

static uint16_t int2ushort(int32_t val)
{
    if (val > USHRT_MAX)
    {
        qWarning() << "This conversion from int to ushort may result in data lost, because the value exceeds USHRT_MAX. Before: " << val << ", After: " << USHRT_MAX;
        return USHRT_MAX;
    }

    if (val < 0)
    {
        qWarning() << "This conversion from int to ushort may result in data lost, because the value is less than 0. Before: " << val << ", After: " << 0;
        return 0;
    }

    return static_cast<uint16_t>(val);
}

static int32_t checkIntUpper(int64_t val)
{
    if(val > static_cast<int64_t>(INT_MAX))
    {
        qWarning() << "The value exceeds INT_MAX. Value: " << val;
        return INT_MAX;
    }
    return static_cast<int32_t>(val);
}

static int32_t checkIntLower(int64_t val)
{
    if(val < static_cast<int64_t>(INT_MIN))
    {
        qWarning() << "The value is less than INT_MIN. Value: " << val;
        return INT_MIN;
    }
    return static_cast<int32_t>(val);
}
#endif
